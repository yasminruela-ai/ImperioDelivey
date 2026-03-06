@startuml
left to right direction

actor Usuario

rectangle Sistema {
 (Visualizar Histórico de Pedidos)
 (Acompanhar Status do Pedido)
}

Usuario --> (Visualizar Histórico de Pedidos)
Usuario --> (Acompanhar Status do Pedido)

@enduml
