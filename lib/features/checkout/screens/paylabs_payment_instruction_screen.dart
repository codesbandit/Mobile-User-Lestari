import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lestar_user/common/widgets/custom_app_bar_widget.dart';
import 'package:lestar_user/common/widgets/custom_snackbar_widget.dart';
import 'package:lestar_user/features/checkout/controllers/checkout_controller.dart';
import 'package:lestar_user/features/loyalty/controllers/loyalty_controller.dart';
import 'package:lestar_user/features/splash/controllers/splash_controller.dart';
import 'package:lestar_user/helper/price_converter.dart';
import 'package:lestar_user/helper/route_helper.dart';
import 'package:lestar_user/util/dimensions.dart';
import 'package:lestar_user/util/styles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PaylabsPaymentInstructionScreen extends StatefulWidget {
  final String paymentId;
  final String paymentType;
  final String category;
  final String instruction;
  final double orderAmount;
  final String orderId;
  final String contactNumber;
  final bool isDeliveryOrder;

  const PaylabsPaymentInstructionScreen({
    super.key,
    required this.paymentId,
    required this.paymentType,
    required this.category,
    required this.instruction,
    required this.orderAmount,
    required this.orderId,
    required this.contactNumber,
    required this.isDeliveryOrder,
  });

  @override
  State<PaylabsPaymentInstructionScreen> createState() =>
      _PaylabsPaymentInstructionScreenState();
}

class _PaylabsPaymentInstructionScreenState
    extends State<PaylabsPaymentInstructionScreen>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  Map<String, dynamic> _instruction = {};
  DateTime? _expiredTime;
  String _remainingTime = '--:--';
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _decodeInstruction();
    _startPolling();
    _startCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isPaid) {
      _checkStatus();
    }
  }

  void _decodeInstruction() {
    try {
      String decoded = utf8.decode(base64Decode(widget.instruction));
      _instruction = jsonDecode(decoded);
      if (_instruction['expired_time'] != null) {
        _expiredTime = _parseExpiredTime(_instruction['expired_time']);
      }
    } catch (_) {}
  }

  DateTime? _parseExpiredTime(dynamic value) {
    if (value == null) {
      return null;
    }
    final String str = value.toString().trim();
    if (str.isEmpty) {
      return null;
    }

    if (RegExp(r'^\d{14}$').hasMatch(str)) {
      try {
        return DateTime(
          int.parse(str.substring(0, 4)),
          int.parse(str.substring(4, 6)),
          int.parse(str.substring(6, 8)),
          int.parse(str.substring(8, 10)),
          int.parse(str.substring(10, 12)),
          int.parse(str.substring(12, 14)),
        );
      } catch (_) {
        return null;
      }
    }

    return DateTime.tryParse(str);
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkStatus(),
    );
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
    _updateCountdown();
  }

  void _updateCountdown() {
    if (_expiredTime == null) {
      return;
    }
    final Duration diff = _expiredTime!.difference(DateTime.now());
    if (diff.isNegative) {
      _pollingTimer?.cancel();
      _countdownTimer?.cancel();
      setState(() => _remainingTime = 'Kadaluarsa');
      Future.delayed(const Duration(seconds: 2), () {
        Get.offNamed(
          RouteHelper.getOrderSuccessRoute(
            widget.orderId,
            'fail',
            widget.orderAmount,
            widget.contactNumber,
            isDeliveryOrder: widget.isDeliveryOrder,
          ),
        );
      });
      return;
    }
    final int hours = diff.inHours;
    final int minutes = diff.inMinutes % 60;
    final int seconds = diff.inSeconds % 60;
    setState(() {
      _remainingTime = hours > 0
          ? '${hours}j ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}d'
          : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _checkStatus() async {
    if (_isPaid) {
      return;
    }
    final String status = await Get.find<CheckoutController>()
        .checkPaylabsStatus(widget.paymentId);
    if (status == 'paid') {
      _isPaid = true;
      _pollingTimer?.cancel();
      _countdownTimer?.cancel();
      double total =
          ((widget.orderAmount / 100) *
          Get.find<SplashController>()
              .configModel!
              .loyaltyPointItemPurchasePoint!);
      Get.find<LoyaltyController>().saveEarningPoint(total.toStringAsFixed(0));
      if (mounted) {
        Get.offNamed(
          RouteHelper.getOrderSuccessRoute(
            widget.orderId,
            'success',
            widget.orderAmount,
            widget.contactNumber,
            isDeliveryOrder: widget.isDeliveryOrder,
          ),
        );
      }
    } else if (status == 'failed') {
      _isPaid = true;
      _pollingTimer?.cancel();
      _countdownTimer?.cancel();
      if (mounted) {
        Get.offNamed(
          RouteHelper.getOrderSuccessRoute(
            widget.orderId,
            'fail',
            widget.orderAmount,
            widget.contactNumber,
            isDeliveryOrder: widget.isDeliveryOrder,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showCustomSnackBar('Berhasil disalin', isError: false);
  }

  Future<void> _downloadQrImage() async {
    final dynamic qrUrl = _instruction['qris_url'];
    if (qrUrl == null || qrUrl.toString().isEmpty) {
      showCustomSnackBar('QR tidak tersedia untuk diunduh.');
      return;
    }

    try {
      final http.Response response = await http.get(
        Uri.parse(qrUrl.toString()),
      );
      if (response.statusCode != 200) {
        showCustomSnackBar('Gagal mengunduh QR.');
        return;
      }

      final Directory directory = await _getDownloadDirectoryWithFallback();
      final String filePath =
          '${directory.path}/paylabs-qris-${widget.paymentId.replaceAll('-', '')}.png';
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      showCustomSnackBar('QR berhasil disimpan: $filePath', isError: false);
    } catch (_) {
      showCustomSnackBar('Gagal mengunduh QR.');
    }
  }

  Future<Directory> _getDownloadDirectoryWithFallback() async {
    if (Platform.isAndroid) {
      final PermissionStatus status = await Permission.storage.request();
      if (status.isGranted || status.isLimited) {
        try {
          return await _getPublicDownloadDirectory();
        } catch (_) {}
      }
    }

    return _getAppDownloadDirectory();
  }

  Future<Directory> _getPublicDownloadDirectory() async {
    if (Platform.isAndroid) {
      final Directory directory = Directory(
        '/storage/emulated/0/Download/Lestari',
      );
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    }

    return _getAppDownloadDirectory();
  }

  Future<Directory> _getAppDownloadDirectory() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final Directory directory = Directory('${documentsDirectory.path}/Lestari');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<void> _openDeepLink() async {
    final dynamic url =
        _instruction['mobile_pay_url'] ??
        _instruction['app_deeplink'] ??
        _instruction['push_pay'] ??
        _instruction['pc_pay_url'];

    if (url != null && url.toString().isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showCustomSnackBar(
          'Tidak dapat membuka aplikasi. Silakan buka secara manual.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic _) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: 'Pembayaran',
          onBackPressed: () => _showExitDialog(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            children: [
              _buildStatusCard(),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              _buildTimerCard(),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              _buildAmountCard(),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              _buildInstructionContent(),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              _buildPollingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Pembayaran',
                style: robotoRegular.copyWith(color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  'Menunggu',
                  style: robotoMedium.copyWith(
                    fontSize: 11,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kode Referensi',
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _instruction['trade_no'] ??
                          widget.paymentId.replaceAll('-', ''),
                      style: robotoMedium.copyWith(
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _copyToClipboard(
                    _instruction['trade_no'] ??
                        widget.paymentId.replaceAll('-', ''),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Salin',
                      style: robotoMedium.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    final bool isExpired = _remainingTime == 'Kadaluarsa';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: isExpired ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: isExpired ? Colors.red : Colors.orange.shade800,
              ),
              const SizedBox(width: 6),
              Text(
                'Waktu Pembayaran Tersisa',
                style: robotoMedium.copyWith(
                  fontSize: 12,
                  color: isExpired ? Colors.red : Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _remainingTime,
            style: robotoBold.copyWith(
              fontSize: 28,
              color: isExpired ? Colors.red : Colors.orange.shade900,
            ),
          ),
          if (_expiredTime != null) ...[
            const SizedBox(height: 4),
            Text(
              'Batas: ${_formatDateTime(_expiredTime!)}',
              style: robotoRegular.copyWith(
                fontSize: 11,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Total Bayar', style: robotoRegular.copyWith(color: Colors.grey)),
        Row(
          children: [
            Text(
              PriceConverter.convertPrice(widget.orderAmount),
              style: robotoBold.copyWith(
                fontSize: 22,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () =>
                  _copyToClipboard(widget.orderAmount.toStringAsFixed(0)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Salin',
                  style: robotoMedium.copyWith(
                    fontSize: 10,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructionContent() {
    switch (widget.category) {
      case 'qris':
        return _buildQrisContent();
      case 'va':
        return _buildVaContent();
      case 'ewallet':
        return _buildEwalletContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildQrisContent() {
    final dynamic qrUrl = _instruction['qris_url'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text('Scan QR Code', style: robotoMedium.copyWith(fontSize: 14)),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (qrUrl != null && qrUrl.toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                qrUrl,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 220,
                  height: 220,
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
              ),
            ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            'Buka aplikasi e-wallet atau mobile banking, pilih Scan QR/QRIS',
            style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (qrUrl != null && qrUrl.toString().isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeLarge),
            OutlinedButton.icon(
              onPressed: _downloadQrImage,
              icon: const Icon(Icons.download_rounded),
              label: Text(
                'Download QR',
                style: robotoMedium.copyWith(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVaContent() {
    final String vaCode = (_instruction['va_code'] ?? '-').toString();
    final String bankName = (_instruction['bank_name'] ?? widget.paymentType)
        .toString();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            bankName,
            style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            vaCode,
            style: robotoBold.copyWith(
              fontSize: 26,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _copyToClipboard(vaCode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.copy,
                    size: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Salin Nomor VA',
                    style: robotoMedium.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _buildHowToPay([
            'Buka aplikasi mobile banking atau ATM $bankName',
            'Pilih menu Transfer atau Bayar',
            'Pilih Virtual Account',
            'Masukkan nomor VA di atas',
            'Konfirmasi jumlah dan selesaikan pembayaran',
          ]),
        ],
      ),
    );
  }

  Widget _buildEwalletContent() {
    final bool hasLink =
        (_instruction['mobile_pay_url'] ??
            _instruction['app_deeplink'] ??
            _instruction['push_pay'] ??
            _instruction['pc_pay_url']) !=
        null;
    final String appName = widget.paymentType.replaceAll('BALANCE', '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Selesaikan pembayaran di aplikasi $appName',
            style: robotoMedium.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          if (hasLink)
            ElevatedButton(
              onPressed: _openDeepLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Buka Aplikasi $appName',
                style: robotoMedium.copyWith(color: Colors.white, fontSize: 15),
              ),
            )
          else
            Text(
              'Buka aplikasi $appName dan selesaikan pembayaran secara manual.',
              style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _buildHowToPay([
            'Klik tombol "Buka Aplikasi $appName" di atas',
            'Atau buka aplikasi $appName secara manual',
            'Konfirmasi pembayaran di dalam aplikasi',
            'Kembali ke halaman ini - status akan otomatis diperbarui',
          ]),
        ],
      ),
    );
  }

  Widget _buildHowToPay(List<String> steps) {
    return ExpansionTile(
      title: Text(
        'Cara Pembayaran',
        style: robotoMedium.copyWith(fontSize: 13),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: steps.asMap().entries.map((MapEntry<int, String> entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.key + 1}. ',
                style: robotoRegular.copyWith(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPollingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Menunggu konfirmasi pembayaran...',
          style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Keluar dari pembayaran?', style: robotoMedium),
        content: Text(
          'Pembayaran belum selesai. Anda masih bisa menyelesaikan pembayaran nanti dari halaman pesanan.',
          style: robotoRegular.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Tetap di sini',
              style: robotoMedium.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _pollingTimer?.cancel();
              _countdownTimer?.cancel();
              Get.back();
              Get.offNamed(
                RouteHelper.getOrderSuccessRoute(
                  widget.orderId,
                  'fail',
                  widget.orderAmount,
                  widget.contactNumber,
                  isDeliveryOrder: widget.isDeliveryOrder,
                ),
              );
            },
            child: Text(
              'Keluar',
              style: robotoMedium.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
