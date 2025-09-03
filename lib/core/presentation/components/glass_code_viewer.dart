/// Glass Code Viewer Component - Multi-language Code Display with Copy-to-Clipboard
///
/// PATTERN: Strategy + Template Method + Observer - Multi-language code display
/// WHERE: Core presentation components for code examples in pattern learning
/// HOW: Strategy for different languages, Template Method for structure, Observer for state
/// WHY: Educational code examples with Tower Defense context and multi-language support
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_theme.dart';
import 'glass_container.dart';
import 'glass_toast.dart';

/// Supported programming languages enumeration
enum CodeLanguage {
  dart('Dart', 'dart', Icons.flutter_dash, Color(0xFF0175C2)),
  typescript('TypeScript', 'typescript', Icons.code, Color(0xFF3178C6)),
  kotlin('Kotlin', 'kotlin', Icons.android, Color(0xFF7F52FF)),
  swift('Swift', 'swift', Icons.phone_iphone, Color(0xFFFA7343)),
  java('Java', 'java', Icons.coffee, Color(0xFFED8B00)),
  csharp('C#', 'csharp', Icons.desktop_windows, Color(0xFF239120));

  const CodeLanguage(this.displayName, this.syntaxName, this.icon, this.color);

  final String displayName;
  final String syntaxName;
  final IconData icon;
  final Color color;
}

/// Observer interface for code viewer events
abstract class CodeViewerObserver {
  void onLanguageChanged(CodeLanguage language);

  void onCodeCopied(CodeLanguage language, String code);

  void onCodeExpanded(bool isExpanded);
}

/// Strategy interface for code generation
abstract class CodeGenerationStrategy {
  String generateCode(String patternName, Map<String, dynamic> context);

  String get syntaxHighlightLanguage;

  List<String> get commonImports;

  String get fileExtension;
}

/// Dart/Flutter code generation strategy
class DartCodeStrategy implements CodeGenerationStrategy {
  @override
  String generateCode(String patternName, Map<String, dynamic> context) {
    final className = context['className'] ?? 'TowerDefenseExample';
    final description =
        context['description'] ?? 'Design Pattern Implementation';

    return '''/// $description - $patternName Pattern
/// Tower Defense Game Implementation
library;

import 'package:flutter/material.dart';

/// PATTERN: $patternName - ${context['patternType'] ?? 'Behavioral'}
/// WHERE: Tower Defense game mechanics
/// HOW: ${context['howImplementation'] ?? 'Implements pattern for tower management'}
/// WHY: ${context['whyUseful'] ?? 'Provides flexible tower behavior system'}
class $className {
  ${_generateDartImplementation(patternName, context)}
}

/// Tower Defense specific implementation
class TowerManager {
  final List<Tower> _towers = [];
  
  void addTower(Tower tower) {
    _towers.add(tower);
    print('Tower added: \${tower.type} at (\${tower.x}, \${tower.y})');
  }
  
  void upgradeTower(int towerId) {
    final tower = _towers.firstWhere((t) => t.id == towerId);
    tower.upgrade();
    print('Tower \${tower.id} upgraded to level \${tower.level}');
  }
}

class Tower {
  final int id;
  final String type;
  final double x, y;
  int level = 1;
  
  Tower(this.id, this.type, this.x, this.y);
  
  void upgrade() => level++;
  void attack(Enemy enemy) => print('Tower \${id} attacking \${enemy.type}');
}

class Enemy {
  final String type;
  int health;
  
  Enemy(this.type, this.health);
}''';
  }

  String _generateDartImplementation(
    String pattern,
    Map<String, dynamic> context,
  ) {
    switch (pattern.toLowerCase()) {
      case 'singleton':
        return '''static TowerDefenseGame? _instance;
  static TowerDefenseGame get instance => _instance ??= TowerDefenseGame._();
  
  TowerDefenseGame._();
  
  int _gold = 100;
  int _lives = 20;
  
  int get gold => _gold;
  int get lives => _lives;
  
  void spendGold(int amount) {
    if (_gold >= amount) {
      _gold -= amount;
      print('Spent \$amount gold. Remaining: \$_gold');
    }
  }''';
      case 'factory':
        return '''static Tower createTower(String type, double x, double y) {
    switch (type) {
      case 'archer':
        return ArcherTower(DateTime.now().millisecondsSinceEpoch, x, y);
      case 'cannon':
        return CannonTower(DateTime.now().millisecondsSinceEpoch, x, y);
      case 'magic':
        return MagicTower(DateTime.now().millisecondsSinceEpoch, x, y);
      default:
        throw ArgumentError('Unknown tower type: \$type');
    }
  }''';
      case 'observer':
        return '''final List<GameObserver> _observers = [];
  
  void addObserver(GameObserver observer) => _observers.add(observer);
  void removeObserver(GameObserver observer) => _observers.remove(observer);
  
  void notifyEnemyDefeated(Enemy enemy) {
    for (final observer in _observers) {
      observer.onEnemyDefeated(enemy);
    }
  }
  
  void notifyWaveCompleted(int waveNumber) {
    for (final observer in _observers) {
      observer.onWaveCompleted(waveNumber);
    }
  }''';
      default:
        return '''// Pattern implementation for $pattern
  void executePattern() {
    print('Executing $pattern pattern in Tower Defense context');
  }''';
    }
  }

  @override
  String get syntaxHighlightLanguage => 'dart';

  @override
  List<String> get commonImports => ['package:flutter/material.dart'];

  @override
  String get fileExtension => '.dart';
}

/// TypeScript code generation strategy
class TypeScriptCodeStrategy implements CodeGenerationStrategy {
  @override
  String generateCode(String patternName, Map<String, dynamic> context) {
    final className = context['className'] ?? 'TowerDefenseExample';
    final description =
        context['description'] ?? 'Design Pattern Implementation';

    return '''// $description - $patternName Pattern
// Tower Defense Game Implementation

/**
 * PATTERN: $patternName - ${context['patternType'] ?? 'Behavioral'}
 * WHERE: Tower Defense game mechanics
 * HOW: ${context['howImplementation'] ?? 'Implements pattern for tower management'}
 * WHY: ${context['whyUseful'] ?? 'Provides flexible tower behavior system'}
 */
class $className {
  ${_generateTypeScriptImplementation(patternName, context)}
}

// Tower Defense specific interfaces and classes
interface ITower {
  id: number;
  type: string;
  x: number;
  y: number;
  level: number;
  upgrade(): void;
  attack(enemy: IEnemy): void;
}

interface IEnemy {
  type: string;
  health: number;
}

class TowerManager {
  private towers: ITower[] = [];
  
  addTower(tower: ITower): void {
    this.towers.push(tower);
    console.log(`Tower added: \${tower.type} at (\${tower.x}, \${tower.y})`);
  }
  
  upgradeTower(towerId: number): void {
    const tower = this.towers.find(t => t.id === towerId);
    if (tower) {
      tower.upgrade();
      console.log(`Tower \${tower.id} upgraded to level \${tower.level}`);
    }
  }
}

class ArcherTower implements ITower {
  constructor(
    public id: number,
    public type: string = 'archer',
    public x: number,
    public y: number,
    public level: number = 1
  ) {}
  
  upgrade(): void {
    this.level++;
  }
  
  attack(enemy: IEnemy): void {
    console.log(`Archer tower \${this.id} shooting at \${enemy.type}`);
    enemy.health -= 10 * this.level;
  }
}''';
  }

  String _generateTypeScriptImplementation(
    String pattern,
    Map<String, dynamic> context,
  ) {
    switch (pattern.toLowerCase()) {
      case 'singleton':
        return '''private static instance: TowerDefenseGame | null = null;
  private gold: number = 100;
  private lives: number = 20;
  
  private constructor() {}
  
  public static getInstance(): TowerDefenseGame {
    if (!TowerDefenseGame.instance) {
      TowerDefenseGame.instance = new TowerDefenseGame();
    }
    return TowerDefenseGame.instance;
  }
  
  public getGold(): number {
    return this.gold;
  }
  
  public spendGold(amount: number): boolean {
    if (this.gold >= amount) {
      this.gold -= amount;
      console.log(`Spent \${amount} gold. Remaining: \${this.gold}`);
      return true;
    }
    return false;
  }''';
      case 'factory':
        return '''public static createTower(type: string, x: number, y: number): ITower {
    const id = Date.now();
    
    switch (type) {
      case 'archer':
        return new ArcherTower(id, x, y);
      case 'cannon':
        return new CannonTower(id, x, y);
      case 'magic':
        return new MagicTower(id, x, y);
      default:
        throw new Error(`Unknown tower type: \${type}`);
    }
  }''';
      case 'observer':
        return '''private observers: GameObserver[] = [];
  
  public addObserver(observer: GameObserver): void {
    this.observers.push(observer);
  }
  
  public removeObserver(observer: GameObserver): void {
    const index = this.observers.indexOf(observer);
    if (index > -1) {
      this.observers.splice(index, 1);
    }
  }
  
  public notifyEnemyDefeated(enemy: IEnemy): void {
    this.observers.forEach(observer => {
      observer.onEnemyDefeated(enemy);
    });
  }''';
      default:
        return '''// Pattern implementation for $pattern
  public executePattern(): void {
    console.log('Executing $pattern pattern in Tower Defense context');
  }''';
    }
  }

  @override
  String get syntaxHighlightLanguage => 'typescript';

  @override
  List<String> get commonImports => [];

  @override
  String get fileExtension => '.ts';
}

/// Kotlin code generation strategy
class KotlinCodeStrategy implements CodeGenerationStrategy {
  @override
  String generateCode(String patternName, Map<String, dynamic> context) {
    final className = context['className'] ?? 'TowerDefenseExample';
    final description =
        context['description'] ?? 'Design Pattern Implementation';

    return '''// $description - $patternName Pattern
// Tower Defense Game Implementation for Android

/**
 * PATTERN: $patternName - ${context['patternType'] ?? 'Behavioral'}
 * WHERE: Tower Defense game mechanics on Android
 * HOW: ${context['howImplementation'] ?? 'Implements pattern for tower management'}
 * WHY: ${context['whyUseful'] ?? 'Provides flexible tower behavior system'}
 */
class $className {
    ${_generateKotlinImplementation(patternName, context)}
}

// Tower Defense specific interfaces and classes
interface Tower {
    val id: Int
    val type: String
    val x: Double
    val y: Double
    var level: Int
    
    fun upgrade()
    fun attack(enemy: Enemy)
}

data class Enemy(
    val type: String,
    var health: Int
)

class TowerManager {
    private val towers = mutableListOf<Tower>()
    
    fun addTower(tower: Tower) {
        towers.add(tower)
        println("Tower added: \${tower.type} at (\${tower.x}, \${tower.y})")
    }
    
    fun upgradeTower(towerId: Int) {
        towers.find { it.id == towerId }?.let { tower ->
            tower.upgrade()
            println("Tower \${tower.id} upgraded to level \${tower.level}")
        }
    }
}

class ArcherTower(
    override val id: Int,
    override val type: String = "archer",
    override val x: Double,
    override val y: Double,
    override var level: Int = 1
) : Tower {
    
    override fun upgrade() {
        level++
    }
    
    override fun attack(enemy: Enemy) {
        println("Archer tower \${id} shooting at \${enemy.type}")
        enemy.health -= 10 * level
    }
}''';
  }

  String _generateKotlinImplementation(
    String pattern,
    Map<String, dynamic> context,
  ) {
    switch (pattern.toLowerCase()) {
      case 'singleton':
        return '''companion object {
        @Volatile
        private var INSTANCE: TowerDefenseGame? = null
        
        fun getInstance(): TowerDefenseGame {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: TowerDefenseGame().also { INSTANCE = it }
            }
        }
    }
    
    private var gold: Int = 100
    private var lives: Int = 20
    
    fun getGold(): Int = gold
    
    fun spendGold(amount: Int): Boolean {
        return if (gold >= amount) {
            gold -= amount
            println("Spent \$amount gold. Remaining: \$gold")
            true
        } else false
    }''';
      case 'factory':
        return '''companion object {
        fun createTower(type: String, x: Double, y: Double): Tower {
            val id = System.currentTimeMillis().toInt()
            
            return when (type) {
                "archer" -> ArcherTower(id, x, y)
                "cannon" -> CannonTower(id, x, y)
                "magic" -> MagicTower(id, x, y)
                else -> throw IllegalArgumentException("Unknown tower type: \$type")
            }
        }
    }''';
      case 'observer':
        return '''private val observers = mutableListOf<GameObserver>()
    
    fun addObserver(observer: GameObserver) {
        observers.add(observer)
    }
    
    fun removeObserver(observer: GameObserver) {
        observers.remove(observer)
    }
    
    fun notifyEnemyDefeated(enemy: Enemy) {
        observers.forEach { it.onEnemyDefeated(enemy) }
    }
    
    fun notifyWaveCompleted(waveNumber: Int) {
        observers.forEach { it.onWaveCompleted(waveNumber) }
    }''';
      default:
        return '''// Pattern implementation for $pattern
    fun executePattern() {
        println("Executing $pattern pattern in Tower Defense context")
    }''';
    }
  }

  @override
  String get syntaxHighlightLanguage => 'kotlin';

  @override
  List<String> get commonImports => [];

  @override
  String get fileExtension => '.kt';
}

/// Swift code generation strategy
class SwiftCodeStrategy implements CodeGenerationStrategy {
  @override
  String generateCode(String patternName, Map<String, dynamic> context) {
    final className = context['className'] ?? 'TowerDefenseExample';
    final description =
        context['description'] ?? 'Design Pattern Implementation';

    return '''// $description - $patternName Pattern
// Tower Defense Game Implementation for iOS

/**
 * PATTERN: $patternName - ${context['patternType'] ?? 'Behavioral'}
 * WHERE: Tower Defense game mechanics on iOS
 * HOW: ${context['howImplementation'] ?? 'Implements pattern for tower management'}
 * WHY: ${context['whyUseful'] ?? 'Provides flexible tower behavior system'}
 */
class $className {
    ${_generateSwiftImplementation(patternName, context)}
}

// Tower Defense specific protocols and classes
protocol Tower {
    var id: Int { get }
    var type: String { get }
    var x: Double { get }
    var y: Double { get }
    var level: Int { get set }
    
    func upgrade()
    func attack(enemy: Enemy)
}

struct Enemy {
    let type: String
    var health: Int
}

class TowerManager {
    private var towers: [Tower] = []
    
    func addTower(_ tower: Tower) {
        towers.append(tower)
        print("Tower added: \\(tower.type) at (\\(tower.x), \\(tower.y))")
    }
    
    func upgradeTower(withId towerId: Int) {
        if let index = towers.firstIndex(where: { \$0.id == towerId }) {
            towers[index].upgrade()
            print("Tower \\(towers[index].id) upgraded to level \\(towers[index].level)")
        }
    }
}

class ArcherTower: Tower {
    let id: Int
    let type: String = "archer"
    let x: Double
    let y: Double
    var level: Int = 1
    
    init(id: Int, x: Double, y: Double) {
        self.id = id
        self.x = x
        self.y = y
    }
    
    func upgrade() {
        level += 1
    }
    
    func attack(enemy: Enemy) {
        print("Archer tower \\(id) shooting at \\(enemy.type)")
        var mutableEnemy = enemy
        mutableEnemy.health -= 10 * level
    }
}''';
  }

  String _generateSwiftImplementation(
    String pattern,
    Map<String, dynamic> context,
  ) {
    switch (pattern.toLowerCase()) {
      case 'singleton':
        return '''static let shared = TowerDefenseGame()
    
    private var gold: Int = 100
    private var lives: Int = 20
    
    private init() {}
    
    func getGold() -> Int {
        return gold
    }
    
    func spendGold(_ amount: Int) -> Bool {
        if gold >= amount {
            gold -= amount
            print("Spent \\(amount) gold. Remaining: \\(gold)")
            return true
        }
        return false
    }''';
      case 'factory':
        return '''static func createTower(type: String, x: Double, y: Double) -> Tower {
        let id = Int(Date().timeIntervalSince1970)
        
        switch type {
        case "archer":
            return ArcherTower(id: id, x: x, y: y)
        case "cannon":
            return CannonTower(id: id, x: x, y: y)
        case "magic":
            return MagicTower(id: id, x: x, y: y)
        default:
            fatalError("Unknown tower type: \\(type)")
        }
    }''';
      case 'observer':
        return '''private var observers: [GameObserver] = []
    
    func addObserver(_ observer: GameObserver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: GameObserver) {
        observers.removeAll { \$0 === observer }
    }
    
    func notifyEnemyDefeated(_ enemy: Enemy) {
        observers.forEach { \$0.onEnemyDefeated(enemy) }
    }
    
    func notifyWaveCompleted(_ waveNumber: Int) {
        observers.forEach { \$0.onWaveCompleted(waveNumber) }
    }''';
      default:
        return '''// Pattern implementation for $pattern
    func executePattern() {
        print("Executing $pattern pattern in Tower Defense context")
    }''';
    }
  }

  @override
  String get syntaxHighlightLanguage => 'swift';

  @override
  List<String> get commonImports => ['Foundation'];

  @override
  String get fileExtension => '.swift';
}

/// Java code generation strategy
class JavaCodeStrategy implements CodeGenerationStrategy {
  @override
  String generateCode(String patternName, Map<String, dynamic> context) {
    final className = context['className'] ?? 'TowerDefenseExample';
    final description =
        context['description'] ?? 'Design Pattern Implementation';

    return '''// $description - $patternName Pattern
// Tower Defense Game Implementation for Java

import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * PATTERN: $patternName - ${context['patternType'] ?? 'Behavioral'}
 * WHERE: Tower Defense game mechanics in Java
 * HOW: ${context['howImplementation'] ?? 'Implements pattern for tower management'}
 * WHY: ${context['whyUseful'] ?? 'Provides flexible tower behavior system'}
 */
public class $className {
    ${_generateJavaImplementation(patternName, context)}
}

// Tower Defense specific interfaces and classes
interface Tower {
    int getId();
    String getType();
    double getX();
    double getY();
    int getLevel();
    void upgrade();
    void attack(Enemy enemy);
}

class Enemy {
    private final String type;
    private int health;
    
    public Enemy(String type, int health) {
        this.type = type;
        this.health = health;
    }
    
    public String getType() { return type; }
    public int getHealth() { return health; }
    public void setHealth(int health) { this.health = health; }
}

class TowerManager {
    private final List<Tower> towers = new ArrayList<>();
    
    public void addTower(Tower tower) {
        towers.add(tower);
        System.out.printf("Tower added: %s at (%.1f, %.1f)%n", 
                         tower.getType(), tower.getX(), tower.getY());
    }
    
    public void upgradeTower(int towerId) {
        towers.stream()
               .filter(t -> t.getId() == towerId)
               .findFirst()
               .ifPresent(tower -> {
                   tower.upgrade();
                   System.out.printf("Tower %d upgraded to level %d%n", 
                                   tower.getId(), tower.getLevel());
               });
    }
}

class ArcherTower implements Tower {
    private final int id;
    private final String type = "archer";
    private final double x, y;
    private int level = 1;
    
    public ArcherTower(int id, double x, double y) {
        this.id = id;
        this.x = x;
        this.y = y;
    }
    
    @Override
    public int getId() { return id; }
    
    @Override
    public String getType() { return type; }
    
    @Override
    public double getX() { return x; }
    
    @Override
    public double getY() { return y; }
    
    @Override
    public int getLevel() { return level; }
    
    @Override
    public void upgrade() { level++; }
    
    @Override
    public void attack(Enemy enemy) {
        System.out.printf("Archer tower %d shooting at %s%n", id, enemy.getType());
        enemy.setHealth(enemy.getHealth() - (10 * level));
    }
}''';
  }

  String _generateJavaImplementation(
    String pattern,
    Map<String, dynamic> context,
  ) {
    switch (pattern.toLowerCase()) {
      case 'singleton':
        return '''private static volatile TowerDefenseGame instance;
    private int gold = 100;
    private int lives = 20;
    
    private TowerDefenseGame() {}
    
    public static TowerDefenseGame getInstance() {
        if (instance == null) {
            synchronized (TowerDefenseGame.class) {
                if (instance == null) {
                    instance = new TowerDefenseGame();
                }
            }
        }
        return instance;
    }
    
    public int getGold() {
        return gold;
    }
    
    public boolean spendGold(int amount) {
        if (gold >= amount) {
            gold -= amount;
            System.out.printf("Spent %d gold. Remaining: %d%n", amount, gold);
            return true;
        }
        return false;
    }''';
      case 'factory':
        return '''public static Tower createTower(String type, double x, double y) {
        int id = (int) System.currentTimeMillis();
        
        switch (type) {
            case "archer":
                return new ArcherTower(id, x, y);
            case "cannon":
                return new CannonTower(id, x, y);
            case "magic":
                return new MagicTower(id, x, y);
            default:
                throw new IllegalArgumentException("Unknown tower type: " + type);
        }
    }''';
      case 'observer':
        return '''private final List<GameObserver> observers = new CopyOnWriteArrayList<>();
    
    public void addObserver(GameObserver observer) {
        observers.add(observer);
    }
    
    public void removeObserver(GameObserver observer) {
        observers.remove(observer);
    }
    
    public void notifyEnemyDefeated(Enemy enemy) {
        for (GameObserver observer : observers) {
            observer.onEnemyDefeated(enemy);
        }
    }
    
    public void notifyWaveCompleted(int waveNumber) {
        for (GameObserver observer : observers) {
            observer.onWaveCompleted(waveNumber);
        }
    }''';
      default:
        return '''// Pattern implementation for $pattern
    public void executePattern() {
        System.out.println("Executing $pattern pattern in Tower Defense context");
    }''';
    }
  }

  @override
  String get syntaxHighlightLanguage => 'java';

  @override
  List<String> get commonImports => ['java.util.*'];

  @override
  String get fileExtension => '.java';
}

/// C# code generation strategy
class CSharpCodeStrategy implements CodeGenerationStrategy {
  @override
  String generateCode(String patternName, Map<String, dynamic> context) {
    final className = context['className'] ?? 'TowerDefenseExample';
    final description =
        context['description'] ?? 'Design Pattern Implementation';

    return '''// $description - $patternName Pattern
// Tower Defense Game Implementation for C#/.NET

using System;
using System.Collections.Generic;
using System.Linq;

namespace TowerDefense.Patterns
{
    /// <summary>
    /// PATTERN: $patternName - ${context['patternType'] ?? 'Behavioral'}
    /// WHERE: Tower Defense game mechanics in C#
    /// HOW: ${context['howImplementation'] ?? 'Implements pattern for tower management'}
    /// WHY: ${context['whyUseful'] ?? 'Provides flexible tower behavior system'}
    /// </summary>
    public class $className
    {
        ${_generateCSharpImplementation(patternName, context)}
    }
    
    // Tower Defense specific interfaces and classes
    public interface ITower
    {
        int Id { get; }
        string Type { get; }
        double X { get; }
        double Y { get; }
        int Level { get; set; }
        
        void Upgrade();
        void Attack(Enemy enemy);
    }
    
    public class Enemy
    {
        public string Type { get; }
        public int Health { get; set; }
        
        public Enemy(string type, int health)
        {
            Type = type;
            Health = health;
        }
    }
    
    public class TowerManager
    {
        private readonly List<ITower> _towers = new List<ITower>();
        
        public void AddTower(ITower tower)
        {
            _towers.Add(tower);
            Console.WriteLine(\$"Tower added: {tower.Type} at ({tower.X}, {tower.Y})");
        }
        
        public void UpgradeTower(int towerId)
        {
            var tower = _towers.FirstOrDefault(t => t.Id == towerId);
            if (tower != null)
            {
                tower.Upgrade();
                Console.WriteLine(\$"Tower {tower.Id} upgraded to level {tower.Level}");
            }
        }
    }
    
    public class ArcherTower : ITower
    {
        public int Id { get; }
        public string Type => "archer";
        public double X { get; }
        public double Y { get; }
        public int Level { get; set; } = 1;
        
        public ArcherTower(int id, double x, double y)
        {
            Id = id;
            X = x;
            Y = y;
        }
        
        public void Upgrade()
        {
            Level++;
        }
        
        public void Attack(Enemy enemy)
        {
            Console.WriteLine(\$"Archer tower {Id} shooting at {enemy.Type}");
            enemy.Health -= 10 * Level;
        }
    }
}''';
  }

  String _generateCSharpImplementation(
    String pattern,
    Map<String, dynamic> context,
  ) {
    switch (pattern.toLowerCase()) {
      case 'singleton':
        return '''private static readonly Lazy<TowerDefenseGame> _instance = 
            new Lazy<TowerDefenseGame>(() => new TowerDefenseGame());
        
        public static TowerDefenseGame Instance => _instance.Value;
        
        private int _gold = 100;
        private int _lives = 20;
        
        private TowerDefenseGame() { }
        
        public int Gold => _gold;
        public int Lives => _lives;
        
        public bool SpendGold(int amount)
        {
            if (_gold >= amount)
            {
                _gold -= amount;
                Console.WriteLine(\$"Spent {amount} gold. Remaining: {_gold}");
                return true;
            }
            return false;
        }''';
      case 'factory':
        return '''public static ITower CreateTower(string type, double x, double y)
        {
            int id = Environment.TickCount;
            
            return type switch
            {
                "archer" => new ArcherTower(id, x, y),
                "cannon" => new CannonTower(id, x, y),
                "magic" => new MagicTower(id, x, y),
                _ => throw new ArgumentException(\$"Unknown tower type: {type}")
            };
        }''';
      case 'observer':
        return '''private readonly List<IGameObserver> _observers = new List<IGameObserver>();
        
        public void AddObserver(IGameObserver observer)
        {
            _observers.Add(observer);
        }
        
        public void RemoveObserver(IGameObserver observer)
        {
            _observers.Remove(observer);
        }
        
        public void NotifyEnemyDefeated(Enemy enemy)
        {
            foreach (var observer in _observers)
            {
                observer.OnEnemyDefeated(enemy);
            }
        }
        
        public void NotifyWaveCompleted(int waveNumber)
        {
            foreach (var observer in _observers)
            {
                observer.OnWaveCompleted(waveNumber);
            }
        }''';
      default:
        return '''// Pattern implementation for $pattern
        public void ExecutePattern()
        {
            Console.WriteLine("Executing $pattern pattern in Tower Defense context");
        }''';
    }
  }

  @override
  String get syntaxHighlightLanguage => 'csharp';

  @override
  List<String> get commonImports => ['System', 'System.Collections.Generic'];

  @override
  String get fileExtension => '.cs';
}

/// Factory for creating code generation strategies
class CodeStrategyFactory {
  static final Map<CodeLanguage, CodeGenerationStrategy> _strategies = {
    CodeLanguage.dart: DartCodeStrategy(),
    CodeLanguage.typescript: TypeScriptCodeStrategy(),
    CodeLanguage.kotlin: KotlinCodeStrategy(),
    CodeLanguage.swift: SwiftCodeStrategy(),
    CodeLanguage.java: JavaCodeStrategy(),
    CodeLanguage.csharp: CSharpCodeStrategy(),
  };

  static CodeGenerationStrategy getStrategy(CodeLanguage language) {
    final strategy = _strategies[language];
    if (strategy == null) {
      throw ArgumentError(
        'No strategy found for language: ${language.displayName}',
      );
    }
    return strategy;
  }

  static List<CodeLanguage> get supportedLanguages => CodeLanguage.values;
}

/// Main Glass Code Viewer Component
class GlassCodeViewer extends StatefulWidget {
  /// Pattern name for code generation
  final String patternName;

  /// Additional context for code generation
  final Map<String, dynamic> context;

  /// List of observers for viewer events
  final List<CodeViewerObserver> observers;

  /// Initial language selection
  final CodeLanguage initialLanguage;

  /// Whether to show expanded view initially
  final bool initiallyExpanded;

  /// Maximum height when collapsed
  final double? collapsedHeight;

  /// Whether to show line numbers
  final bool showLineNumbers;

  /// Whether to enable word wrap
  final bool enableWordWrap;

  const GlassCodeViewer({
    super.key,
    required this.patternName,
    this.context = const {},
    this.observers = const [],
    this.initialLanguage = CodeLanguage.dart,
    this.initiallyExpanded = false,
    this.collapsedHeight = 300,
    this.showLineNumbers = true,
    this.enableWordWrap = false,
  });

  @override
  State<GlassCodeViewer> createState() => _GlassCodeViewerState();
}

class _GlassCodeViewerState extends State<GlassCodeViewer>
    with SingleTickerProviderStateMixin {
  late CodeLanguage _selectedLanguage;
  late bool _isExpanded;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  String _generatedCode = '';
  bool _isCodeLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
    _isExpanded = widget.initiallyExpanded;

    _expandController = AnimationController(
      duration: AppTheme.mediumAnimation,
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _expandController.value = 1.0;
    }

    _generateCode();
    Log.debug(
      'GlassCodeViewer: Initialized for pattern "${widget.patternName}"',
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() {
      _isCodeLoading = true;
    });

    try {
      final strategy = CodeStrategyFactory.getStrategy(_selectedLanguage);
      final code = strategy.generateCode(widget.patternName, widget.context);

      setState(() {
        _generatedCode = code;
        _isCodeLoading = false;
      });

      Log.debug('Code generated for ${_selectedLanguage.displayName}');
    } catch (e) {
      Log.error('Failed to generate code: $e');
      setState(() {
        _generatedCode = '// Error generating code: $e';
        _isCodeLoading = false;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: _generatedCode));

      if (mounted) {
        GlassToast.success(
          context: context,
          message: 'Code copied to clipboard!',
          duration: const Duration(seconds: 2),
        );
      }

      // Notify observers
      for (final observer in widget.observers) {
        observer.onCodeCopied(_selectedLanguage, _generatedCode);
      }

      Log.debug(
        'Code copied to clipboard for ${_selectedLanguage.displayName}',
      );
    } catch (e) {
      Log.error('Failed to copy code: $e');
      if (mounted) {
        GlassToast.error(
          context: context,
          message: 'Failed to copy code',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void _onLanguageChanged(CodeLanguage newLanguage) {
    if (newLanguage != _selectedLanguage) {
      setState(() {
        _selectedLanguage = newLanguage;
      });

      _generateCode();

      // Notify observers
      for (final observer in widget.observers) {
        observer.onLanguageChanged(newLanguage);
      }

      Log.debug('Language changed to ${newLanguage.displayName}');
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }

    // Notify observers
    for (final observer in widget.observers) {
      observer.onCodeExpanded(_isExpanded);
    }

    Log.debug('Code viewer ${_isExpanded ? 'expanded' : 'collapsed'}');
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer.panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.spacingM),
          _buildLanguageTabs(),
          const SizedBox(height: AppTheme.spacingM),
          _buildCodeContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: _selectedLanguage.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Icon(
            _selectedLanguage.icon,
            color: _selectedLanguage.color,
            size: 20,
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.patternName} Pattern',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_selectedLanguage.displayName} Implementation',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        // Copy button
        GlassContainer.button(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          onTap: _copyToClipboard,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.copy, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Copy',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        // Expand/Collapse button
        GlassContainer.button(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          onTap: _toggleExpanded,
          child: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CodeLanguage.values.map((language) {
          final isSelected = language == _selectedLanguage;

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingS),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              margin: const EdgeInsets.all(AppTheme.spacingS),
              borderRadius: AppTheme.radiusM,
              blurIntensity: 8.0,
              borderColor: isSelected
                  ? language.color.withValues(alpha: 0.5)
                  : AppTheme.glassBorder,
              borderWidth: isSelected ? 1.5 : 1.0,
              opacity: isSelected ? 0.2 : 0.1,
              onTap: () => _onLanguageChanged(language),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    language.icon,
                    size: 16,
                    color: isSelected ? language.color : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    language.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? language.color
                          : AppTheme.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCodeContent() {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final height = _isExpanded
            ? null
            : widget.collapsedHeight! * (1.0 - _expandAnimation.value * 0.3);

        return SizedBox(
          height: height,
          child: _isCodeLoading ? _buildLoadingState() : _buildCodeDisplay(),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_selectedLanguage.color),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Generating ${_selectedLanguage.displayName} code...',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeDisplay() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderColor: _selectedLanguage.color.withValues(alpha: 0.2),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: widget.showLineNumbers
              ? _buildCodeWithLineNumbers()
              : _buildCodeText(),
        ),
      ),
    );
  }

  Widget _buildCodeWithLineNumbers() {
    final lines = _generatedCode.split('\n');
    final maxLineNumber = lines.length;
    final lineNumberWidth = maxLineNumber.toString().length * 10.0 + 20.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line numbers
        Container(
          width: lineNumberWidth,
          padding: const EdgeInsets.only(right: AppTheme.spacingS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: lines.asMap().entries.map((entry) {
              return Container(
                height: 20,
                alignment: Alignment.centerRight,
                child: Text(
                  '${entry.key + 1}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                    fontFamily: 'Courier',
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Vertical separator
        Container(
          width: 1,
          color: AppTheme.glassBorder,
          margin: const EdgeInsets.only(right: AppTheme.spacingS),
        ),
        // Code content
        Expanded(child: _buildCodeText()),
      ],
    );
  }

  Widget _buildCodeText() {
    return SelectableText(
      _generatedCode,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontFamily: 'Courier',
        color: AppTheme.textPrimary,
        height: 1.4,
      ),
    );
  }
}
