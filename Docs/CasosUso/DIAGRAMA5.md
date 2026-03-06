@startuml
left to right direction

actor Usuario

rectangle Sistema {
 (Atualizar Status do Pedido)
 (Enviar Notificação)
 (Visualizar Atualização do Pedido)
}

Usuario --> (Visualizar Atualização do Pedido)
(Atualizar Status do Pedido) --> (Enviar Notificação)

@enduml
