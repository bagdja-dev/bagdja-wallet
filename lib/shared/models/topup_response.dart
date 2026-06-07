
class TopUpResponse {
  final bool success;
  final String? checkoutUrl;
  final String? refNumber;
  final String? expiryTime;

  TopUpResponse({
    required this.success,
    this.checkoutUrl,
    this.refNumber,
    this.expiryTime,
  });

  factory TopUpResponse.fromJson(Map<String, dynamic> json) {
    return TopUpResponse(
      success: json['success'] as bool,
      checkoutUrl: (json['checkoutUrl'] ?? json['checkout_url']) as String?,
      refNumber: (json['refNumber'] ?? json['ref_number']) as String?,
      expiryTime: (json['expiryTime'] ?? json['expiry_time']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'checkoutUrl': checkoutUrl,
      'refNumber': refNumber,
      'expiryTime': expiryTime,
    };
  }
}

