/// Firestore User Profile Data Source
///
/// PATTERN: Data Access Object (DAO) - Firestore operations
/// WHERE: Data layer datasource for user profile storage
/// HOW: Implements CRUD operations with Firestore database
/// WHY: Isolates Firestore implementation from business logic
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/utils/result.dart';
import 'package:design_patterns/features/user_profile/data/models/user_profile_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../user_profile.dart';

/// Abstract interface for profile data source
abstract class ProfileDataSource {
  Future<Result<UserProfileModel, Exception>> getProfile(String uid);

  Future<Result<UserProfileModel, Exception>> createProfile(
    UserProfileModel profile,
  );

  Future<Result<UserProfileModel, Exception>> updateProfile(
    UserProfileModel profile,
  );

  Future<Result<void, Exception>> updateField(
    String uid,
    String field,
    dynamic value,
  );

  Future<Result<void, Exception>> deleteProfile(String uid);

  Future<Result<String, Exception>> uploadProfileImage(
    String uid,
    File imageFile,
  );

  Future<Result<void, Exception>> deleteProfileImage(String uid);

  Future<Result<List<UserProfileModel>, Exception>> searchProfiles({
    String? email,
    String? displayName,
    int? limit,
  });

  Stream<UserProfileModel?> profileStream(String uid);
}

/// Firestore implementation of profile data source
///
/// PATTERN: Data Access Object - Firestore integration
///
/// In Tower Defense context, this datasource handles all Firestore
/// operations for user profiles including CRUD operations, image
/// upload to Firebase Storage, and real-time profile updates.
class FirestoreProfileDataSource implements ProfileDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const String _profilesCollection = 'user_profiles';
  static const String _profileImagesPath = 'profile_images';

  FirestoreProfileDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance {
    Log.debug('FirestoreProfileDataSource initialized');
  }

  @override
  Future<Result<UserProfileModel, Exception>> getProfile(String uid) async {
    try {
      Log.debug('Getting profile for user: $uid');

      final docSnapshot = await _firestore
          .collection(_profilesCollection)
          .doc(uid)
          .get();

      if (!docSnapshot.exists) {
        Log.warning('Profile not found for user: $uid');
        return Result.failure(Exception('Profile not found for user: $uid'));
      }

      final profile = UserProfileModel.fromFirestore(docSnapshot);
      Log.success('Profile retrieved for user: $uid');
      return Result.success(profile);
    } on FirebaseException catch (e) {
      Log.error('Firestore error getting profile: ${e.code} - ${e.message}');
      return Result.failure(Exception('Failed to get profile: ${e.message}'));
    } catch (e) {
      Log.error('Unexpected error getting profile: $e');
      return Result.failure(Exception('Failed to get profile: $e'));
    }
  }

  @override
  Future<Result<UserProfileModel, Exception>> createProfile(
    UserProfileModel profile,
  ) async {
    try {
      Log.debug('Creating profile for user: ${profile.uid}');

      final docRef = _firestore
          .collection(_profilesCollection)
          .doc(profile.uid);

      // Check if profile already exists
      final existingDoc = await docRef.get();
      if (existingDoc.exists) {
        Log.warning('Profile already exists for user: ${profile.uid}');
        return Result.failure(
          Exception('Profile already exists for user: ${profile.uid}'),
        );
      }

      // Create the profile document
      await docRef.set(profile.toFirestoreData());

      // Retrieve the created profile to get server timestamps
      final createdDoc = await docRef.get();
      final createdProfile = UserProfileModel.fromFirestore(createdDoc);

      Log.success('Profile created for user: ${profile.uid}');
      return Result.success(createdProfile);
    } on FirebaseException catch (e) {
      Log.error('Firestore error creating profile: ${e.code} - ${e.message}');
      return Result.failure(
        Exception('Failed to create profile: ${e.message}'),
      );
    } catch (e) {
      Log.error('Unexpected error creating profile: $e');
      return Result.failure(Exception('Failed to create profile: $e'));
    }
  }

  @override
  Future<Result<UserProfileModel, Exception>> updateProfile(
    UserProfileModel profile,
  ) async {
    try {
      Log.debug('Updating profile for user: ${profile.uid}');

      final docRef = _firestore
          .collection(_profilesCollection)
          .doc(profile.uid);

      // Update the profile document
      await docRef.update(profile.toFirestoreData(isUpdate: true));

      // Retrieve the updated profile to get server timestamps
      final updatedDoc = await docRef.get();

      if (!updatedDoc.exists) {
        return Result.failure(
          Exception('Profile not found after update: ${profile.uid}'),
        );
      }

      final updatedProfile = UserProfileModel.fromFirestore(updatedDoc);

      Log.success('Profile updated for user: ${profile.uid}');
      return Result.success(updatedProfile);
    } on FirebaseException catch (e) {
      Log.error('Firestore error updating profile: ${e.code} - ${e.message}');
      return Result.failure(
        Exception('Failed to update profile: ${e.message}'),
      );
    } catch (e) {
      Log.error('Unexpected error updating profile: $e');
      return Result.failure(Exception('Failed to update profile: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> updateField(
    String uid,
    String field,
    dynamic value,
  ) async {
    try {
      Log.debug('Updating field $field for user: $uid');

      await _firestore.collection(_profilesCollection).doc(uid).update({
        field: value,
        'last_updated_at': FieldValue.serverTimestamp(),
      });

      Log.success('Field $field updated for user: $uid');
      return Result.success(null);
    } on FirebaseException catch (e) {
      Log.error('Firestore error updating field: ${e.code} - ${e.message}');
      return Result.failure(Exception('Failed to update field: ${e.message}'));
    } catch (e) {
      Log.error('Unexpected error updating field: $e');
      return Result.failure(Exception('Failed to update field: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> deleteProfile(String uid) async {
    try {
      Log.warning('Deleting profile for user: $uid');

      // Delete profile image if it exists
      await deleteProfileImage(uid);

      // Delete the profile document
      await _firestore.collection(_profilesCollection).doc(uid).delete();

      Log.success('Profile deleted for user: $uid');
      return Result.success(null);
    } on FirebaseException catch (e) {
      Log.error('Firestore error deleting profile: ${e.code} - ${e.message}');
      return Result.failure(
        Exception('Failed to delete profile: ${e.message}'),
      );
    } catch (e) {
      Log.error('Unexpected error deleting profile: $e');
      return Result.failure(Exception('Failed to delete profile: $e'));
    }
  }

  @override
  Future<Result<String, Exception>> uploadProfileImage(
    String uid,
    File imageFile,
  ) async {
    try {
      Log.debug('Uploading profile image for user: $uid');

      if (!imageFile.existsSync()) {
        return Result.failure(Exception('Image file does not exist'));
      }

      // Create a reference to the profile image
      final imageRef = _storage
          .ref()
          .child(_profileImagesPath)
          .child('$uid.jpg');

      // Upload the image
      final uploadTask = imageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_by': uid,
            'upload_timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload completion
      final snapshot = await uploadTask;

      if (snapshot.state != TaskState.success) {
        return Result.failure(Exception('Image upload failed'));
      }

      // Get the download URL
      final downloadUrl = await imageRef.getDownloadURL();

      // Update the profile with the new image URL
      await updateField(uid, 'photo_url', downloadUrl);

      Log.success('Profile image uploaded for user: $uid');
      return Result.success(downloadUrl);
    } on FirebaseException catch (e) {
      Log.error('Firebase error uploading image: ${e.code} - ${e.message}');
      return Result.failure(Exception('Failed to upload image: ${e.message}'));
    } catch (e) {
      Log.error('Unexpected error uploading image: $e');
      return Result.failure(Exception('Failed to upload image: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> deleteProfileImage(String uid) async {
    try {
      Log.debug('Deleting profile image for user: $uid');

      final imageRef = _storage
          .ref()
          .child(_profileImagesPath)
          .child('$uid.jpg');

      try {
        await imageRef.delete();
        Log.success('Profile image deleted for user: $uid');
      } on FirebaseException catch (e) {
        if (e.code == 'object-not-found') {
          Log.debug('No profile image found to delete for user: $uid');
        } else {
          rethrow;
        }
      }

      // Update profile to remove image URL
      await updateField(uid, 'photo_url', null);

      return Result.success(null);
    } on FirebaseException catch (e) {
      Log.error('Firebase error deleting image: ${e.code} - ${e.message}');
      return Result.failure(Exception('Failed to delete image: ${e.message}'));
    } catch (e) {
      Log.error('Unexpected error deleting image: $e');
      return Result.failure(Exception('Failed to delete image: $e'));
    }
  }

  @override
  Future<Result<List<UserProfileModel>, Exception>> searchProfiles({
    String? email,
    String? displayName,
    int? limit,
  }) async {
    try {
      Log.debug('Searching profiles with filters');

      Query query = _firestore.collection(_profilesCollection);

      // Apply filters
      if (email != null && email.isNotEmpty) {
        query = query.where('email', isEqualTo: email);
      }

      if (displayName != null && displayName.isNotEmpty) {
        query = query
            .where('display_name', isGreaterThanOrEqualTo: displayName)
            .where('display_name', isLessThan: '${displayName}z');
      }

      // Apply limit
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      final profiles = querySnapshot.docs
          .map(
            (doc) => UserProfileModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();

      Log.success('Found ${profiles.length} profiles matching search criteria');
      return Result.success(profiles);
    } on FirebaseException catch (e) {
      Log.error('Firestore error searching profiles: ${e.code} - ${e.message}');
      return Result.failure(
        Exception('Failed to search profiles: ${e.message}'),
      );
    } catch (e) {
      Log.error('Unexpected error searching profiles: $e');
      return Result.failure(Exception('Failed to search profiles: $e'));
    }
  }

  @override
  Stream<UserProfileModel?> profileStream(String uid) {
    Log.debug('Setting up profile stream for user: $uid');

    return _firestore
        .collection(_profilesCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return UserProfileModel.fromFirestore(snapshot);
          }
          return null;
        })
        .handleError((error) {
          Log.error('Profile stream error: $error');
        });
  }

  /// Batch update multiple profiles (admin operation)
  Future<Result<void, Exception>> batchUpdateProfiles(
    List<UserProfileModel> profiles,
  ) async {
    try {
      Log.debug('Batch updating ${profiles.length} profiles');

      final batch = _firestore.batch();

      for (final profile in profiles) {
        final docRef = _firestore
            .collection(_profilesCollection)
            .doc(profile.uid);
        batch.update(docRef, profile.toFirestoreData(isUpdate: true));
      }

      await batch.commit();

      Log.success('Batch update completed for ${profiles.length} profiles');
      return Result.success(null);
    } on FirebaseException catch (e) {
      Log.error('Firestore error in batch update: ${e.code} - ${e.message}');
      return Result.failure(Exception('Batch update failed: ${e.message}'));
    } catch (e) {
      Log.error('Unexpected error in batch update: $e');
      return Result.failure(Exception('Batch update failed: $e'));
    }
  }

  /// Get profile statistics
  Future<Result<Map<String, dynamic>, Exception>> getProfileStats() async {
    try {
      Log.debug('Getting profile statistics');

      final querySnapshot = await _firestore
          .collection(_profilesCollection)
          .get();

      final profiles = querySnapshot.docs
          .map(
            (doc) => UserProfileModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();

      final stats = {
        'total_profiles': profiles.length,
        'verified_emails': profiles.where((p) => p.isEmailVerified).length,
        'google_users': profiles
            .where((p) => p.authProvider == 'google')
            .length,
        'apple_users': profiles.where((p) => p.authProvider == 'apple').length,
        'email_users': profiles
            .where((p) => p.authProvider == 'email_password')
            .length,
        'anonymous_users': profiles
            .where((p) => p.authProvider == 'anonymous')
            .length,
        'active_accounts': profiles
            .where((p) => p.accountStatusEnum == AccountStatus.active)
            .length,
        'pending_deletion': profiles
            .where((p) => p.accountStatusEnum == AccountStatus.pendingDeletion)
            .length,
        'total_games_played': profiles.fold<int>(
          0,
          (int sum, UserProfileModel p) => sum + p.gamesPlayed,
        ),
        'total_games_won': profiles.fold<int>(
          0,
          (int sum, UserProfileModel p) => sum + p.gamesWon,
        ),
      };

      Log.success('Profile statistics calculated');
      return Result.success(stats);
    } on FirebaseException catch (e) {
      Log.error('Firestore error getting stats: ${e.code} - ${e.message}');
      return Result.failure(
        Exception('Failed to get profile stats: ${e.message}'),
      );
    } catch (e) {
      Log.error('Unexpected error getting stats: $e');
      return Result.failure(Exception('Failed to get profile stats: $e'));
    }
  }
}
