# Design Patterns Rules - Tower Defense App

## CONTEXTO DE LA APLICACIÓN
Esta aplicación es un **demostrador de patrones de diseño** implementado como un juego de Tower Defense educativo.

---

## 📋 REGLAS DEFINIDAS POR EL USUARIO

### Reglas de Negocio del Juego
| # | Regla Original | Patrón(es) Aplicable(s) |
|---|----------------|-------------------------|
| 1 | La app debe mostrar implementación de patrones de diseño | **Todos los patrones** |
| 2 | Enemigos: hormigas, saltamontes, cucarachas | **Factory Pattern** (creación), **Strategy Pattern** (comportamientos) |
| 3 | Torres: arqueros (flechas), lanza piedras (piedras anchas) | **Factory Pattern** (creación), **Strategy Pattern** (ataques) |
| 4 | El camino tiene muros | **Composite Pattern** (estructura del mapa) |
| 5 | El mapa tiene muros y la casa | **Composite Pattern** (elementos del mapa), **Builder Pattern** (construcción) |
| 6 | Jugador tiene XP y nivel | **Observer Pattern** (cambios de estado), **State Pattern** (niveles) |
| 7 | Matar enemigos da XP | **Observer Pattern** (eventos), **Command Pattern** (acciones) |
| 8 | Subir nivel otorga puntos de evolución | **Observer Pattern** (level up events) |
| 9 | Árbol de evolución mejora torres, balas y trampas | **Decorator Pattern** (upgrades), **Command Pattern** (mejoras) |
| 10 | Trampas ralentizan o inmovilizan | **State Pattern** (efectos), **Strategy Pattern** (tipos de efectos) |

---

## 🎯 REGLAS ADICIONALES (PARA COMPLETAR PATRONES)

### Reglas Agregadas para Demostración Completa
| # | Regla Adicional | Patrón(es) Objetivo |
|---|-----------------|---------------------|
| A1 | Sistema único de gestión de juego (GameManager) | **Singleton Pattern** |
| A2 | Carga diferida de recursos gráficos y sonidos | **Proxy Pattern** |
| A3 | Interfaz simplificada para operaciones complejas del motor | **Facade Pattern** |
| A4 | Sistema de efectos en cadena (daño → ralentización → muerte) | **Chain of Responsibility** |
| A5 | Adaptación entre diferentes tipos de torres heredadas | **Adapter Pattern** |
| A6 | Separación entre lógica de juego y renderizado | **Bridge Pattern** |
| A7 | Flujo estándar de turnos del juego con pasos customizables | **Template Method Pattern** |
| A8 | Sistema de notificaciones de eventos del juego | **Mediator Pattern** |
| A9 | Almacenamiento y restauración de estados de partida | **Memento Pattern** |
| A10 | Clonación eficiente de configuraciones de torres | **Prototype Pattern** |

---

## 🏗️ MATRIZ DE IMPLEMENTACIÓN OBLIGATORIA

### Patrones Creacionales
- ✅ **Factory Method**: Creación de enemigos y torres
- ✅ **Abstract Factory**: Familias de elementos (torres + proyectiles)
- ✅ **Builder**: Construcción de mapas y árboles de evolución
- ✅ **Prototype**: Clonación de configuraciones
- ✅ **Singleton**: GameManager único

### Patrones Estructurales
- ✅ **Adapter**: Compatibilidad entre tipos de torres
- ✅ **Bridge**: Separación lógica/renderizado
- ✅ **Composite**: Estructura jerárquica del mapa
- ✅ **Decorator**: Sistema de upgrades
- ✅ **Facade**: Interfaz simplificada del motor
- ✅ **Proxy**: Carga lazy de recursos

### Patrones Comportamentales
- ✅ **Chain of Responsibility**: Sistema de efectos en cadena
- ✅ **Command**: Acciones del jugador y upgrades
- ✅ **Mediator**: Comunicación entre componentes
- ✅ **Memento**: Save/Load de partidas
- ✅ **Observer**: Eventos del juego (XP, level up)
- ✅ **State**: Estados de enemigos y torres
- ✅ **Strategy**: Comportamientos intercambiables
- ✅ **Template Method**: Flujo de turnos del juego

---

## 📁 ESTRUCTURA ESPECÍFICA DEL PROYECTO

```
lib/
├── core/
│   ├── patterns/           # Implementaciones base de patrones
│   ├── constants/          # Constantes del juego
│   └── utils/              # Utilidades
├── features/
│   ├── game/               # Lógica principal del juego
│   │   ├── data/           # Modelos y repositorios de datos
│   │   ├── domain/         # Entidades, casos de uso, ViewModels
│   │   └── presentation/   # UI del juego
│   ├── enemies/            # Sistema de enemigos
│   ├── towers/             # Sistema de torres
│   ├── player/             # Sistema de jugador (XP, nivel)
│   ├── evolution/          # Árbol de evolución
│   ├── map/                # Sistema de mapas
│   └── traps/              # Sistema de trampas
└── main.dart
```

---

## 🧪 REGLAS DE TESTING ESPECÍFICAS

### Cobertura por Patrón
- Cada patrón implementado debe tener **tests específicos** que demuestren su funcionamiento
- **Mínimo 3 test cases** por patrón implementado
- **Integration tests** que muestren la interacción entre patrones

### Documentación Obligatoria
- Cada clase debe tener **comentarios explicando QUÉ patrón implementa**
- **Diagramas UML** en comentarios para patrones complejos
- **README.md** con explicación de cada patrón y su uso en el contexto

### Visualización Obligatoria por Patrón
- **OBLIGATORIO**: Cada patrón debe tener su **grafo/diagrama específico**
- **CONTEXTO**: Usar ejemplos del Tower Defense (enemigos, torres, jugador, etc.)
- **HERRAMIENTA**: PlantUML con node-plantuml
- **FORMATO**: SVG generado automáticamente
- **EJEMPLO**: Si patrón Singleton → diagrama mostrando GameManager único
- **UBICACIÓN**: `docs/generated/[PatternName].svg`

---

## 🎮 REGLAS DE IMPLEMENTACIÓN DEL JUEGO

### Flujo Principal
1. **Inicialización**: Singleton GameManager
2. **Creación de Mapa**: Builder Pattern
3. **Spawn de Enemigos**: Factory Pattern + Strategy
4. **Colocación de Torres**: Factory + Command Pattern
5. **Sistema de Combate**: Observer + Chain of Responsibility
6. **Progression**: Observer + State Pattern
7. **Upgrades**: Decorator + Command Pattern

### Requisitos de UI
- **Demostrar visualmente** cada patrón en acción
- **Panel de información** mostrando qué patrón se está utilizando
- **Logs en pantalla** de eventos importantes (para observar patrones)

---

## 📏 MÉTRICAS DE ÉXITO

- ✅ **18 patrones implementados** mínimo
- ✅ **Cobertura +80%** en tests
- ✅ **Documentación completa** de cada patrón
- ✅ **Funcionalidad del juego** operativa
- ✅ **Demostración visual** de patrones en UI
