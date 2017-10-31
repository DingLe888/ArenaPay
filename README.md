## 目的
集成**支付宝**和**微信**支付，对外暴露接口，方便微应用组件的调用。

## 配置要求
1. 在主工程中的TARGETS中的info选项卡的URL Types中添加两个URL Type。一个是微信的identifier 和appid，另外一个是支付宝的indentifier。
2. 添加URL Schemes白名单， 在Xcode中，选择你的工程设置项，选中“TARGETS”一栏，在“info”标签栏的“LSApplicationQueriesSchemes“添加微信和支付宝的identifier.
3. 要使你的程序启动后微信终端能响应你的程序，必须在代码中向微信终端注册你的id,在AppDelegate 的 didFinishLaunchingWithOptions 函数中注册最好。

 ```
 let WXKey = "wx085a8685d1892707";

 WXPayManager.setWXAppKey(WXKey)
 ```
* 重写AppDelegate的handleOpenURL和openURL方法：配置支付宝客户端和微信客户端返回url处理方法。有3个open方法，主要是为了适应不同iOS版本。
  
```
func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        WXPayManager.applicationOpen(url)
        AliPayManager.applicationOpen(url)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        AliPayManager.applicationOpen(url)

        WXPayManager.applicationOpen(url)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        AliPayManager.applicationOpen(url)
        
        WXPayManager.applicationOpen(url)
        return true
    }    
```
       
## 资源文件
* arena.plugins.plist文件主要是配合Arena而做的一个维护api和函数实现之间的映射关系plist文件，不需要去关心。
* pod install 结束后需要手动把Resources中的bundle文件引入主工程。