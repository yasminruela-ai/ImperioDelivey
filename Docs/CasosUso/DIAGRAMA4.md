@startuml
left to right direction

actor Usuario

rectangle Sistema {
 (Visualizar Catálogo)
 (Visualizar Detalhes do Produto)
}

Usuario --> (Visualizar Catálogo)
Usuario --> (Visualizar Detalhes do Produto)

@enduml
