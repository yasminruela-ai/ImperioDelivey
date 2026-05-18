const { adminFirebase } = require("./config/firebase");

const messaging = adminFirebase.messaging();

const STATUS_MESSAGES = {
  aceito:            { title: "Pedido aceito! 🎉",      body: "A cozinha já recebeu seu pedido." },
  em_preparo:        { title: "Em preparo 👨‍🍳",         body: "Seu pedido está sendo preparado." },
  saiu_para_entrega: { title: "Saiu para entrega! 🛵", body: "Seu pedido está a caminho." },
  entregue:          { title: "Entregue! ✅",            body: "Aproveite seu pedido!" },
  cancelado:         { title: "Pedido cancelado ❌",     body: "Seu pedido foi cancelado." },
};

async function sendOrderStatusNotification(fcmToken, status, pedidoId) {
  const msg = STATUS_MESSAGES[status];
  if (!msg || !fcmToken) return;

  try {
    await messaging.send({
      token: fcmToken,
      notification: {
        title: msg.title,
        body: msg.body,
      },
      data: {
        pedidoId,
        status,
        type: "order_status",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "imperios_orders",
          sound: "default",
        },
      },
    });
  } catch (error) {
    // token inválido ou dispositivo offline — não bloqueia a atualização de status
    console.warn("[FCM] falha ao enviar notificação:", error.message);
  }
}

module.exports = { sendOrderStatusNotification };
