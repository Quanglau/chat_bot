import 'dart:convert';
import '../chatdata/my_data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// gửi yêu cầu tới các API của OpenAI để lấy thông tin
class ApiChatBotServices {
  static FlutterSecureStorage storage = const FlutterSecureStorage();
  static String baseUrl_3 = 'https://api.openai.com/v1/completions';
  static String baseUrl_3_5 = 'https://api.openai.com/v1/chat/completions';
  static String baseUrl_image = 'https://api.openai.com/v1/images/generations';
  //sử dụng API của OpenAI để gửi tin nhắn
  static sendMessage(List<String> message) async {
    print('apikey: ${MyData.myApiKey}');
    String model = await storage.read(key: 'model_chat') ?? 'both';
    String? result;
    result = await model3_5(message!);
    return result;
  }

  static Future<String> model3_5(List<String> message) async {
    var length = message.length;
    var res = await http.post(Uri.parse(baseUrl_3_5),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${MyData.myApiKey}',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": length > 4 ? message[4] : 'Xin chào'},
            {"role": "assistant", "content": length > 3 ? message[3] : 'Chào bạn, tôi có thể giúp gì?'},
            {"role": "user", "content": length > 2 ? message[2] : 'Bạn khỏe không?'},
            {
              "role": "assistant",
              "content": length > 1 ? message[1] : 'Tôi khỏe, cảm ơn bạn, bạn cần tôi giúp gì không?'
            },
            {"role": "user", "content": message[0]}
          ],
          'temperature': 0,
          'max_tokens': 400,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
          'stop': ['Human:', ' AI']
        }));

    if (res.statusCode == 200) {
      var data = jsonDecode(utf8.decode(res.bodyBytes));
      var msg = data['choices'][0]['message']['content'];
      return msg;
    } else {
      print('Failed to fetch data: ${res.statusCode}');
      return '';
    }
  }

  static translate(String? message) async {
    var res = await http.post(Uri.parse(baseUrl_3_5),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${MyData.myApiKey}',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content": "Take the 3 main keywords in the following sentence and translate them into English: $message"
            }
          ],
          'temperature': 0,
          'max_tokens': 80,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
          'stop': ['Human:', ' AI']
        }));

    if (res.statusCode == 200) {
      var data = jsonDecode(utf8.decode(res.bodyBytes));
      var msg = data['choices'][0]['message']['content'];
      return msg;
    } else {
      print('Failed to fetch data: ${res.statusCode}');
      return '';
    }
  }

  static generateImage(String text) async {
    List<String> result = [];
    var res = await http.post(Uri.parse(baseUrl_image),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${MyData.myApiKey}',
        },
        body: jsonEncode({
          "prompt": text,
          "n": 4,
          "size": "256x256",
        }));

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body.toString());
      result.add(data['data'][0]['url'].toString());
      result.add(data['data'][1]['url'].toString());
      result.add(data['data'][2]['url'].toString());
      result.add(data['data'][3]['url'].toString());
      return result;
    } else {
      print("Failed to fetch image ${res.statusCode}");
    }
  }

  static buildQuestions(String? message) async {
    var res = await http.post(Uri.parse(baseUrl_3_5),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${MyData.myApiKey}',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": "Hãy viết cho tôi 4 câu hỏi về chủ đề trong đoạn văn sau: $message"}
          ],
          'temperature': 0,
          'max_tokens': 300,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
          'stop': ['Human:', ' AI']
        }));
    if (res.statusCode == 200) {
      var data = jsonDecode(utf8.decode(res.bodyBytes));
      var msg = data['choices'][0]['message']['content'];
      return msg;
    } else {
      print('Failed to fetch data: ${res.statusCode}');
      return '';
    }
  }

}
