import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GmailService {
  static String senderEmail = "";
  static String appPassword = "";

  static Future<bool> sendEmail(String recipientEmail, String code) async {
    try {
      senderEmail = dotenv.env['GOOGLE_EMAIL'] ?? "";
      appPassword = dotenv.env['GOOGLE_APP_PASSWORD'] ?? "";

      if (senderEmail.isEmpty || appPassword.isEmpty) {
        print('Gmail credentials not found in environment variables');
        return false;
      }

      final smtpServer = gmail(senderEmail, appPassword);

      final message = Message()
        ..from = Address(senderEmail, 'DPR Car Rentals Verification')
        ..recipients.add(recipientEmail)
        ..subject = 'DPR Car Rentals - Verification Code'
        ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333;">Email Verification</h2>
          <p>Your verification code for DPR Car Rentals is:</p>
          <div style="background-color: #f5f5f5; padding: 20px; text-align: center; border-radius: 5px; margin: 20px 0;">
            <h1 style="color: #333; margin: 0; font-size: 36px;">$code</h1>
          </div>
          <p>Please enter this code in the app to verify your email address.</p>
          <p>This code will expire in 10 minutes.</p>
          <hr style="margin: 30px 0;">
          <p style="color: #888; font-size: 14px;">
            If you didn't request this verification, please ignore this email.
          </p>
        </div>
        ''';

      final sendReport = await send(message, smtpServer);
      print('Email sent successfully: ${sendReport.toString()}');
      return true;
    } on MailerException catch (e) {
      print('Failed to send email: ${e.message}');
      for (var problem in e.problems) {
        print('Problem: ${problem.code} - ${problem.msg}');
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
    return false;
  }
}
