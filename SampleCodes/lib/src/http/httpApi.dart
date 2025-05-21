//单例模式
import 'package:dio/dio.dart';

class HttpApi {
  static const String baseUrl = 'https://linktop.ltd/';
  static final HttpApi _httpApi = HttpApi._internal();

  factory HttpApi() {
    return _httpApi;
  }

  HttpApi._internal();

  //对dio进行配置
  Dio dio =Dio();

  void init() {
    dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 5)
      ..headers = {
        "Content-Type": "application/x-www-form-urlencoded",
      }
      ..validateStatus = (int? status) {
        return status != null && status > 0;
      };
    dio.interceptors.add(LogInterceptor(requestBody: true));
    // dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
    //   // 在请求发送之前处理
    //   print('请求前的数据：${options.data}');
    //   print('请求头：${options.headers}');
    //   print('请求URL：${options.uri}');
    //   handler.next(options);
      
    // }, onResponse: (Response response, ResponseInterceptorHandler handler) async {
    //   handler.next(response);
    // }, onError: (DioException e, ErrorInterceptorHandler handler) {
    //   // 错误处理
    //   print('请求错误：${e.message}');
    //   print('错误类型：${e.type}');

    //   // 继续处理错误
    //   handler.next(e);
    // },));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path, {Map<String, dynamic>? data}) async {
    return await dio.delete(path, data: data);
  }

  //文件下载
  Future<Response> download(String path, String savePath,
      {ProgressCallback? onReceiveProgress}) async {
    return await dio.download(path, savePath, onReceiveProgress: onReceiveProgress);
  }
}
