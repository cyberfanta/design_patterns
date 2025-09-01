#!/bin/bash

# Complete Documentation Generator for Design Patterns App
DIAGRAMS_PATH=${1:-"docs/diagrams"}
OUTPUT_PATH=${2:-"docs/generated"}
FORMAT=${3:-"svg"}

echo "🚀 Generating complete documentation..."

# Create directories
mkdir -p "$DIAGRAMS_PATH" "$OUTPUT_PATH"

# Function to generate pattern diagram
generate_pattern_diagram() {
    local pattern_name=$1
    local pattern_type=$2 
    local description=$3
    
    cat > "$DIAGRAMS_PATH/$pattern_name.puml" << EOF
@startuml $pattern_name
!theme vibrant
skinparam backgroundColor transparent
skinparam classBackgroundColor #E8F5E8
skinparam classBorderColor #2E7D32

title $pattern_name Pattern - Tower Defense Context
note top : $description

' Pattern implementation will be auto-generated based on context

@enduml
EOF
    
    echo "📄 Generated: $DIAGRAMS_PATH/$pattern_name.puml"
}

# Generate all pattern templates
echo "📊 Generating Pattern Diagrams..."

# Creational Patterns
generate_pattern_diagram "FactoryMethod" "Creational" "Enemy and Tower Creation System"
generate_pattern_diagram "AbstractFactory" "Creational" "Game Element Families"
generate_pattern_diagram "Builder" "Creational" "Map Construction"
generate_pattern_diagram "Prototype" "Creational" "Configuration Cloning"
generate_pattern_diagram "Singleton" "Creational" "GameManager Control"

# Structural Patterns
generate_pattern_diagram "Adapter" "Structural" "Legacy Compatibility"
generate_pattern_diagram "Bridge" "Structural" "Logic/Rendering Separation"
generate_pattern_diagram "Composite" "Structural" "Map Hierarchy"
generate_pattern_diagram "Decorator" "Structural" "Upgrade System"
generate_pattern_diagram "Facade" "Structural" "Engine Interface"
generate_pattern_diagram "Proxy" "Structural" "Lazy Loading"

# Behavioral Patterns
generate_pattern_diagram "ChainOfResponsibility" "Behavioral" "Effect Processing"
generate_pattern_diagram "Command" "Behavioral" "Player Actions"
generate_pattern_diagram "Mediator" "Behavioral" "Component Communication"
generate_pattern_diagram "Memento" "Behavioral" "Save/Load State"
generate_pattern_diagram "Observer" "Behavioral" "Event Notifications"
generate_pattern_diagram "State" "Behavioral" "Entity States"
generate_pattern_diagram "Strategy" "Behavioral" "Interchangeable Behaviors"
generate_pattern_diagram "TemplateMethod" "Behavioral" "Turn Flow Template"

# Generate architecture overview
cat > "$DIAGRAMS_PATH/Architecture_Overview.puml" << EOF
@startuml Architecture_Overview
!theme vibrant

package "Presentation Layer" <<Rectangle>> {
    [Pages] <<UI>>
    [Widgets] <<UI>>  
    [State Management] <<Logic>>
}

package "Domain Layer" <<Rectangle>> {
    [ViewModels] <<Logic>>
    [Use Cases] <<Business>>
    [Entities] <<Model>>
    [Repository Contracts] <<Interface>>
}

package "Data Layer" <<Rectangle>> {
    [Repositories] <<Implementation>>
    [Data Sources] <<External>>
    [Models] <<DTO>>
}

package "External Services" <<Cloud>> {
    [Firebase] <<Service>>
    [SQLite] <<Database>>
    [Device APIs] <<System>>
}

[Pages] --> [State Management]
[State Management] --> [ViewModels]
[ViewModels] --> [Use Cases]
[Use Cases] --> [Repository Contracts]
[Repositories] ..|> [Repository Contracts]
[Repositories] --> [Data Sources]
[Data Sources] --> [Firebase]
[Data Sources] --> [SQLite]
[Data Sources] --> [Device APIs]

note right of [State Management] : Creational: MVC\\nStructural: MVP\\nBehavioral: MVVM-C\\nGlobal: MVVM

@enduml
EOF

# Convert all PlantUML to images
echo "🎨 Converting PlantUML to images..."
for puml_file in "$DIAGRAMS_PATH"/*.puml; do
    if [ -f "$puml_file" ]; then
        base_name=$(basename "$puml_file" .puml)
        output_file="$OUTPUT_PATH/$base_name.$FORMAT"
        
        echo "  Converting: $(basename "$puml_file")"
        node-plantuml "$puml_file" -o "$output_file" -f "$FORMAT"
        
        if [ -f "$output_file" ]; then
            echo "  ✅ Generated: $output_file"
        else
            echo "  ❌ Failed: $output_file"
        fi
    fi
done

# Generate Dart documentation
echo "📚 Generating Dart API Documentation..."
if command -v dart &> /dev/null; then
    dart doc --output docs/api 2>/dev/null && echo "✅ Dart documentation generated" || echo "⚠️  Dart doc generation skipped"
else
    echo "⚠️  Dart not found - skipping API documentation"
fi

echo ""
echo "✅ Documentation generation complete!"
echo "📂 Pattern diagrams: $OUTPUT_PATH"
echo "📊 Total diagrams: $(ls -1 "$OUTPUT_PATH"/*.$FORMAT 2>/dev/null | wc -l)"
echo "📚 API docs: docs/api/index.html"
