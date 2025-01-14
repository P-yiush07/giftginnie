class OtpVerificationModel {
  final String verificationId;
  final String authToken;

  OtpVerificationModel({
    required this.verificationId,
    required this.authToken,
  });

  factory OtpVerificationModel.fromJson(Map<String, dynamic> json) {
    return OtpVerificationModel(
      verificationId: json['verification_id'],
      authToken: json['authToken'],
    );
  }
}