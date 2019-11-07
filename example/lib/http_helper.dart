import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
class HttpHelper {
  static const GET = "GET";
  static const POST = "POST";
  static const baseUrl = "http://47.106.10.50:8888/app_server/";
  static Dio _dio;
  PersistCookieJar _cookieJar;///Cookie持久化
  HttpHelper._instance() {
    _dio = Dio();
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = 5000;
    _dio.options.receiveTimeout = 10000;
    //_initDio();
  }
  static HttpHelper _netUtil;
  factory HttpHelper() {
    return _netUtil ??= HttpHelper._instance();///使用工厂构造函数来实现单例
  }

  /*
  void _initDio() async{
    var directory = await getApplicationDocumentsDirectory();
    var path = Directory(join(directory.path, "cookie")).path;
    _cookieJar = PersistCookieJar(dir: path);
    _dio.interceptors.add(CookieManager(_cookieJar));
  }
  */
  Future<Response> request(url,{data,String method = GET})async{
    try{
      _dio.options.method = method;
      var response = await _dio.request(url,data: data);
      return response;
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}