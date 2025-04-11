import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:u_teen/models/order_model.dart';

class EmailService {
  static Future<void> sendOrderToSeller(Order order) async {
    try {
      // Implementasi sebenarnya tergantung backend yang digunakan
      // Contoh menggunakan Firebase atau API sendiri:
      debugPrint('Mengirim email ke: ${order.merchantEmail}');
      debugPrint('Subjek: Pesanan Baru #${order.id}');
      debugPrint('Isi: Anda menerima pesanan baru dari ${order.customerName}');
      
      // Contoh implementasi nyata mungkin:
      // await FirebaseFunctions.instance.call('sendEmail', {
      //   'to': order.merchantEmail,
      //   'subject': 'Pesanan Baru #${order.id}',
      //   'body': _buildEmailBody(order),
      // });
    } catch (e) {
      debugPrint('Gagal mengirim email: $e');
      throw Exception('Gagal mengirim notifikasi ke seller');
    }
  }

  static String _buildEmailBody(Order order) {
    return '''
Detail Pesanan:
ID: ${order.id}
Pelanggan: ${order.customerName}
Waktu Pengambilan: ${DateFormat('dd/MM/yyyy HH:mm').format(order.pickupTime)}
Catatan: ${order.notes ?? '-'}

Daftar Item:
${order.items.map((item) => '- ${item.name} (${item.quantity}x)').join('\n')}

Total: Rp ${NumberFormat('#,###').format(order.totalPrice)}
''';
  }
}