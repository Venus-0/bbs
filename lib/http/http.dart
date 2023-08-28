import 'dart:convert';

import 'package:bbs/utils/sharedPreferenceUtil.dart';
import 'package:bbs/utils/toast.dart';
import 'package:dio/dio.dart';

enum HttpType { GET, POST }

class Http {
  static Future<Map> request(String url, HttpType requestType, data, {CancelToken? cancelToken}) async {
    print("url:$url");
    Dio _dio = Dio();
    tokenInter(_dio);
    Response? response;
    try {
      Map<String, dynamic> headers = new Map();
      headers = await getCookie();
      Options options = new Options(headers: headers);
      if (requestType == HttpType.GET) {
        response = await _dio.get(url, queryParameters: data, options: options, cancelToken: cancelToken);
      } else if (requestType == HttpType.POST) {
        // try {
        dynamic returnData;
        FormData formData = FormData.fromMap(data);
        returnData = await _dio.post(url, data: formData, options: options, cancelToken: cancelToken);
        if (returnData is Response) {
          response = returnData;
        } else {
          response = await _dio.post(url, data: data, options: options, cancelToken: cancelToken);
        }
        print("url:" + url);
      }
      print("结果；" + response.toString());
      try {
        ///解析返回数据
        if (response!.data is String) {
          return jsonDecode(response.data);
        }
        return response.data;
      } catch (e) {
        ///网络请求异常
        Map<String, dynamic> map = {};
        map['code'] = 500;
        map['result'] = "";
        map['msg'] = "出错了";
        return map;
      }
    } on DioException catch (e) {
      ///异常请求处理
      try {
        return json.decode(e.response.toString());
      } catch (e) {
        Map<String, dynamic> map = {};
        map['code'] = 400;
        map['result'] = "";
        map['msg'] = "出错了";
        return map;
      }
    }
  }

  static Future<Map<String, dynamic>> getCookie() async {
    Map<String, dynamic> headers = {};
    headers['user'] = await SharedPreferenceUtil.getCookie();
    print("cookie $headers");
    return headers;
  }

  //拦截器部分
  //version4.0.0
  static tokenInter(Dio? dio) {
    dio!.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      // Do something before request is sent
      return handler.next(options); //continue
      // If you want to resolve the request with some custom data，
      // you can resolve a `Response` object eg: return `dio.resolve(response)`.
      // If you want to reject the request with a error message,
      // you can reject a `DioError` object eg: return `dio.reject(dioError)`
    }, onResponse: (response, handler) {
      // Do something with response data
      if ((response.data is Map) && response.data['code'] == 401) {
        SharedPreferenceUtil.remove(SharedPreferenceUtil.COOKIE);
        try {
          Toast.showToast(response.data['msg']);
        } catch (e, f) {
          print(e);
          print(f);
        }
      }

      return handler.next(response); // continue
      // If you want to reject the request with a error message,
      // you can reject a `DioError` object eg: return `dio.reject(dioError)`
    }, onError: (DioException e, handler) {
      // Do something with response error
      if (e.response != null) {
        // if ((e.response!.data is Map) && e.response!.data['code'] == 401) {
        //   SharedPreferencesUtil.remove(SharedPreferencesUtil.KEY_COOKIE);
        //   try{
        //     Toast.showToast(e.response!.data['msg']);
        //   }catch(e,f){
        //     print(e);
        //     print(f);

        //   }
        // }
      }

      return handler.next(e); //continue
      // If you want to resolve the request with some custom data，
      // you can resolve a `Response` object eg: return `dio.resolve(response)`.
    }));
  }
}
