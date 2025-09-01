/// Builder Pattern - Tower Defense Context
///
/// PATTERN: Builder - Constructs complex objects step by step
/// WHERE: Map construction with walls, paths, house, and evolution tree building
/// HOW: Director uses builders to construct complex objects with many optional parts
/// WHY: Allows step-by-step construction of complex objects with many configurations
library;

import 'package:equatable/equatable.dart';

/// Complex product - Game Map
class GameMap extends Equatable {
  final int width;
  final int height;
  final List<Wall> walls;
  final Path path;
  final House house;
  final List<TrapPosition> trapPositions;
  final String difficulty;
  final String theme;

  const GameMap({
    required this.width,
    required this.height,
    required this.walls,
    required this.path,
    required this.house,
    required this.trapPositions,
    required this.difficulty,
    required this.theme,
  });

  @override
  List<Object> get props => [
    width,
    height,
    walls,
    path,
    house,
    trapPositions,
    difficulty,
    theme,
  ];
}

/// Map components
class Wall extends Equatable {
  final double x;
  final double y;
  final double width;
  final double height;
  final String material;

  const Wall({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.material,
  });

  @override
  List<Object> get props => [x, y, width, height, material];
}

class Path extends Equatable {
  final List<PathPoint> points;
  final double width;
  final String surface;

  const Path({
    required this.points,
    required this.width,
    required this.surface,
  });

  @override
  List<Object> get props => [points, width, surface];
}

class PathPoint extends Equatable {
  final double x;
  final double y;

  const PathPoint(this.x, this.y);

  @override
  List<Object> get props => [x, y];
}

class House extends Equatable {
  final double x;
  final double y;
  final double width;
  final double height;
  final int health;
  final String style;

  const House({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.health,
    required this.style,
  });

  @override
  List<Object> get props => [x, y, width, height, health, style];
}

class TrapPosition extends Equatable {
  final double x;
  final double y;
  final String type;

  const TrapPosition({required this.x, required this.y, required this.type});

  @override
  List<Object> get props => [x, y, type];
}

/// Abstract Builder interface
abstract class MapBuilder {
  void reset();

  void setDimensions(int width, int height);

  void setDifficulty(String difficulty);

  void setTheme(String theme);

  void addWall(
    double x,
    double y,
    double width,
    double height,
    String material,
  );

  void buildPath(List<PathPoint> points, double width, String surface);

  void placeHouse(
    double x,
    double y,
    double width,
    double height,
    int health,
    String style,
  );

  void addTrapPosition(double x, double y, String type);

  GameMap build();
}

/// Concrete Builder - Basic Map
class BasicMapBuilder implements MapBuilder {
  late int _width;
  late int _height;
  late List<Wall> _walls;
  late Path _path;
  late House _house;
  late List<TrapPosition> _trapPositions;
  late String _difficulty;
  late String _theme;

  BasicMapBuilder() {
    reset();
  }

  @override
  void reset() {
    _width = 800;
    _height = 600;
    _walls = [];
    _path = const Path(points: [], width: 50, surface: 'dirt');
    _house = const House(
      x: 0,
      y: 0,
      width: 100,
      height: 100,
      health: 100,
      style: 'basic',
    );
    _trapPositions = [];
    _difficulty = 'easy';
    _theme = 'forest';
  }

  @override
  void setDimensions(int width, int height) {
    _width = width;
    _height = height;
  }

  @override
  void setDifficulty(String difficulty) {
    _difficulty = difficulty;
  }

  @override
  void setTheme(String theme) {
    _theme = theme;
  }

  @override
  void addWall(
    double x,
    double y,
    double width,
    double height,
    String material,
  ) {
    _walls.add(
      Wall(x: x, y: y, width: width, height: height, material: material),
    );
  }

  @override
  void buildPath(List<PathPoint> points, double width, String surface) {
    _path = Path(points: points, width: width, surface: surface);
  }

  @override
  void placeHouse(
    double x,
    double y,
    double width,
    double height,
    int health,
    String style,
  ) {
    _house = House(
      x: x,
      y: y,
      width: width,
      height: height,
      health: health,
      style: style,
    );
  }

  @override
  void addTrapPosition(double x, double y, String type) {
    _trapPositions.add(TrapPosition(x: x, y: y, type: type));
  }

  @override
  GameMap build() {
    final result = GameMap(
      width: _width,
      height: _height,
      walls: List.from(_walls),
      path: _path,
      house: _house,
      trapPositions: List.from(_trapPositions),
      difficulty: _difficulty,
      theme: _theme,
    );
    reset(); // Reset for next build
    return result;
  }
}

/// Concrete Builder - Advanced Map with more features
class AdvancedMapBuilder implements MapBuilder {
  late int _width;
  late int _height;
  late List<Wall> _walls;
  late Path _path;
  late House _house;
  late List<TrapPosition> _trapPositions;
  late String _difficulty;
  late String _theme;

  AdvancedMapBuilder() {
    reset();
  }

  @override
  void reset() {
    _width = 1200;
    _height = 800;
    _walls = [];
    _path = const Path(points: [], width: 60, surface: 'stone');
    _house = const House(
      x: 0,
      y: 0,
      width: 150,
      height: 150,
      health: 200,
      style: 'fortress',
    );
    _trapPositions = [];
    _difficulty = 'hard';
    _theme = 'desert';
  }

  @override
  void setDimensions(int width, int height) {
    _width = width;
    _height = height;
  }

  @override
  void setDifficulty(String difficulty) {
    _difficulty = difficulty;
  }

  @override
  void setTheme(String theme) {
    _theme = theme;
  }

  @override
  void addWall(
    double x,
    double y,
    double width,
    double height,
    String material,
  ) {
    // Advanced builder adds reinforced walls
    _walls.add(
      Wall(
        x: x,
        y: y,
        width: width,
        height: height,
        material: 'reinforced_$material',
      ),
    );
  }

  @override
  void buildPath(List<PathPoint> points, double width, String surface) {
    // Advanced builder creates wider paths with better surfaces
    _path = Path(
      points: points,
      width: width + 20,
      surface: 'reinforced_$surface',
    );
  }

  @override
  void placeHouse(
    double x,
    double y,
    double width,
    double height,
    int health,
    String style,
  ) {
    // Advanced builder creates stronger houses
    _house = House(
      x: x,
      y: y,
      width: width,
      height: height,
      health: health + 100,
      style: 'fortress_$style',
    );
  }

  @override
  void addTrapPosition(double x, double y, String type) {
    _trapPositions.add(TrapPosition(x: x, y: y, type: 'advanced_$type'));
  }

  @override
  GameMap build() {
    final result = GameMap(
      width: _width,
      height: _height,
      walls: List.from(_walls),
      path: _path,
      house: _house,
      trapPositions: List.from(_trapPositions),
      difficulty: _difficulty,
      theme: _theme,
    );
    reset();
    return result;
  }
}

/// Director - Orchestrates the building process
class MapDirector {
  /// Build a basic level map
  GameMap buildBasicLevel(MapBuilder builder) {
    builder.reset();
    builder.setDimensions(800, 600);
    builder.setDifficulty('easy');
    builder.setTheme('forest');

    // Create path from entrance to house
    builder.buildPath(
      [
        const PathPoint(0, 300),
        const PathPoint(200, 300),
        const PathPoint(200, 100),
        const PathPoint(600, 100),
        const PathPoint(600, 300),
        const PathPoint(800, 300),
      ],
      50,
      'dirt',
    );

    // Place house at the end
    builder.placeHouse(700, 250, 100, 100, 100, 'cottage');

    // Add boundary walls
    builder.addWall(0, 0, 800, 20, 'stone'); // Top
    builder.addWall(0, 580, 800, 20, 'stone'); // Bottom
    builder.addWall(0, 0, 20, 600, 'stone'); // Left
    builder.addWall(780, 0, 20, 600, 'stone'); // Right

    // Add some trap positions
    builder.addTrapPosition(150, 250, 'slow');
    builder.addTrapPosition(350, 150, 'freeze');
    builder.addTrapPosition(550, 250, 'slow');

    return builder.build();
  }

  /// Build an advanced level map
  GameMap buildAdvancedLevel(MapBuilder builder) {
    builder.reset();
    builder.setDimensions(1200, 800);
    builder.setDifficulty('hard');
    builder.setTheme('volcano');

    // Create complex winding path
    builder.buildPath(
      [
        const PathPoint(0, 400),
        const PathPoint(300, 400),
        const PathPoint(300, 200),
        const PathPoint(600, 200),
        const PathPoint(600, 600),
        const PathPoint(900, 600),
        const PathPoint(900, 300),
        const PathPoint(1200, 300),
      ],
      60,
      'lava_rock',
    );

    // Place fortified house
    builder.placeHouse(1050, 250, 150, 100, 300, 'fortress');

    // Add complex wall structures
    builder.addWall(0, 0, 1200, 30, 'obsidian'); // Top
    builder.addWall(0, 770, 1200, 30, 'obsidian'); // Bottom
    builder.addWall(0, 0, 30, 800, 'obsidian'); // Left
    builder.addWall(1170, 0, 30, 800, 'obsidian'); // Right

    // Add internal maze walls
    builder.addWall(200, 100, 20, 200, 'stone');
    builder.addWall(500, 300, 20, 200, 'stone');
    builder.addWall(800, 100, 20, 400, 'stone');

    // Add strategic trap positions
    builder.addTrapPosition(250, 350, 'damage');
    builder.addTrapPosition(550, 150, 'slow');
    builder.addTrapPosition(850, 550, 'freeze');
    builder.addTrapPosition(950, 250, 'damage');

    return builder.build();
  }
}

/// Facade for easy map creation
class MapFactory {
  static final _director = MapDirector();
  static final _basicBuilder = BasicMapBuilder();
  static final _advancedBuilder = AdvancedMapBuilder();

  static GameMap createBasicMap() => _director.buildBasicLevel(_basicBuilder);

  static GameMap createAdvancedMap() =>
      _director.buildAdvancedLevel(_advancedBuilder);

  static GameMap createCustomMap(MapBuilder builder, String type) {
    switch (type) {
      case 'basic':
        return _director.buildBasicLevel(builder);
      case 'advanced':
        return _director.buildAdvancedLevel(builder);
      default:
        return _director.buildBasicLevel(builder);
    }
  }
}
