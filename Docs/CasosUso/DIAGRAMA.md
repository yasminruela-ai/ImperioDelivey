@startuml
left to right direction

actor Usuario

rectangle Sistema {
 (Visualizar Catálogo)
 (Adicionar ao Carrinho)
 (Finalizar Pedido)
}

Usuario --> (Visualizar Catálogo)
Usuario --> (Adicionar ao Carrinho)
Usuario --> (Finalizar Pedido)

@enduml
