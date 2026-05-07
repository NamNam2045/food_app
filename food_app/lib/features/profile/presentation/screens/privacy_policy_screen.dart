import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chính sách bảo mật')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: const [
          _PolicySection(
            title: '1. Dữ liệu chúng tôi thu thập',
            body:
                'FoodRush thu thập thông tin tài khoản, địa chỉ giao hàng, lịch sử đơn hàng '
                'và dữ liệu thiết bị cần thiết để vận hành dịch vụ.',
          ),
          _PolicySection(
            title: '2. Mục đích sử dụng dữ liệu',
            body:
                'Dữ liệu được dùng để xử lý đơn hàng, hỗ trợ khách hàng, cá nhân hóa trải nghiệm '
                'và cải thiện chất lượng dịch vụ.',
          ),
          _PolicySection(
            title: '3. Chia sẻ dữ liệu',
            body:
                'Thông tin cần thiết của đơn hàng được chia sẻ với nhà hàng/đơn vị giao hàng để hoàn tất giao dịch. '
                'Chúng tôi không bán dữ liệu cá nhân cho bên thứ ba.',
          ),
          _PolicySection(
            title: '4. Lưu trữ và bảo mật',
            body:
                'Chúng tôi áp dụng biện pháp kỹ thuật phù hợp để bảo vệ dữ liệu. '
                'Token truy cập được lưu trữ an toàn trên thiết bị.',
          ),
          _PolicySection(
            title: '5. Quyền của người dùng',
            body:
                'Bạn có thể yêu cầu cập nhật thông tin cá nhân, thay đổi địa chỉ hoặc đóng tài khoản '
                'theo quy định pháp luật hiện hành.',
          ),
          _PolicySection(
            title: '6. Liên hệ',
            body:
                'Nếu có câu hỏi liên quan đến bảo mật, vui lòng liên hệ: privacy@foodrush.vn.',
          ),
          SizedBox(height: 8),
          Text(
            'Cập nhật lần cuối: 30/04/2026',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}
