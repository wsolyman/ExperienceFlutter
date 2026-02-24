class  ForgetPasswordresponse {
  final int status;
  final String message;
  //final dynamic data;

  ForgetPasswordresponse({
    required this.status,
    required this.message,
  //  required this.data,
  });

  factory ForgetPasswordresponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordresponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
     // data: json['data'],
    );
  }
}
class  CheckOtpresponse {
  final int status;
  final String resetToken;
  //final dynamic data;

  CheckOtpresponse({
    required this.status,
    required this.resetToken,
    //  required this.data,
  });

  factory CheckOtpresponse.fromJson(Map<String, dynamic> json) {
    return CheckOtpresponse(
      status: json['status'] ?? 0,
      resetToken: json['resetToken'] ?? '',
      // data: json['data'],
    );
  }
}