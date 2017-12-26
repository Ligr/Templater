//
//  RequestAction.swift
//  BalanceBy
//
//  Created by Alex on 1/13/17.
//  Copyright © 2017 Home. All rights reserved.
//

import Foundation
import Alamofire

public final class RequestAction: BaseAction {

    fileprivate enum HeaderKey: String {
        case referer = "Referer"
        case userAgent = "User-Agent"
    }
    fileprivate enum ContextKey: String {
        case lastOpenedUrl = "RequestAction.lastOpenedUrlKey"
    }
    fileprivate enum RequestType: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case postData = "POST_DATA"
        case postMultipart = "POST_MULTIPART"
    }

    fileprivate let valueProcessor: ValueProcessor
    fileprivate let userAgentValue = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0) Gecko/20100101 Firefox/52.0"//"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36"
    fileprivate var httpManager: Alamofire.SessionManager?

    public var includeHiddenParams: (include: Bool, tagValue: String?)?
    public var requestParams = [String: String]()
    public var headerParams = [String: String]()

    public init(attributes: ActionAttributes, valueProcessor: ValueProcessor) {
        self.valueProcessor = valueProcessor
        super.init(attributes: attributes)
    }
    
    required public init(attributes: ActionAttributes) {
        fatalError("init(attributes:) has not been implemented")
    }

    public override func copy() -> ActionProtocol {
        let request = RequestAction(attributes: attributes, valueProcessor: valueProcessor)
        request.includeHiddenParams = self.includeHiddenParams
        request.requestParams = self.requestParams
        request.headerParams = self.headerParams
        request.elseAction = self.elseAction?.copy()
        var resultNextActions = [ActionProtocol]()
        for action in nextActions {
            resultNextActions.append(action.copy())
        }
        request.nextActions = resultNextActions
        return request
    }

    public override func execute(data: VariableType?, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        logger?.log(attributes)
        logger?.log("\n\(context)")
        guard let urlStr = attributes["url", context]?.stringValue(), let url = URL(string: urlStr) else {
            callback(nil, ActionError.missingAttribute(name: "url"))
            return
        }
        guard let requestType = self.requestType else {
            callback(nil, ActionError.invalidParameter(details: "<request>: unsupported request type"))
            return
        }
        processHeaderParams(context: context)
        processRequestParams(context: context, data: data)
        let responseEncoding = self.encoding
        httpManager = makeSessionManager(headers: headerParams)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        logger?.log("request headers:\n\(headerParams)")
        logger?.log("request params:\n\(requestParams)")
        switch requestType {
        case .get:
            httpManager?.request(url, method: .get, parameters: requestParams, encoding: URLEncoding.default, headers: headerParams).validate().responseString(queue: dispatchQueue, encoding: responseEncoding) { [weak self] (response) in
                self?.requestFinished(with: response, context: context, callback: callback)
            }
        case .post:
            httpManager?.request(url, method: .post, parameters: requestParams, encoding: URLEncoding.default, headers: headerParams).validate().responseString(queue: dispatchQueue, encoding: responseEncoding) { [weak self] (response) in
                self?.requestFinished(with: response, context: context, callback: callback)
            }
        case .put:
            if let data = requestParams["data"], let json = jsonFromRawString(data) {
                httpManager?.upload(json, to: url, method: .put, headers: headerParams).validate().responseString(queue: dispatchQueue, encoding: responseEncoding) { [weak self] (response) in
                    self?.requestFinished(with: response, context: context, callback: callback)
                }
            } else {
                httpManager?.request(url, method: .put, parameters: requestParams, encoding: URLEncoding.httpBody, headers: headerParams).validate().responseString(queue: dispatchQueue, encoding: responseEncoding) { [weak self] (response) in
                    self?.requestFinished(with: response, context: context, callback: callback)
                }
            }
        case .postData:
            guard let dataStr = requestParams["data"], let data = dataStr.data(using: .utf8) else {
                callback(nil, ActionError.generic(message: "<request>: POST_DATA requires 'data' parameter"))
                return
            }
            httpManager?.upload(data, to: url).validate().responseString(queue: dispatchQueue, encoding: responseEncoding) { [weak self] (response) in
                self?.requestFinished(with: response, context: context, callback: callback)
            }
        case .postMultipart:
            httpManager?.upload(multipartFormData: { (formData) in
                for param in self.requestParams {
                    if let paramData = param.value.data(using: .utf8) {
                        formData.append(paramData, withName: param.key)
                    }
                }
            }, to: url, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let request, _, _):
                    request.validate().responseString(queue: dispatchQueue, encoding: responseEncoding) { [weak self] (response) in
                        self?.requestFinished(with: response, context: context, callback: callback)
                    }
                case .failure(let error):
                    callback(nil, error)
                }
            })
            break
        }
        context.registerVariable(name: ContextKey.lastOpenedUrl.rawValue, value: .string(url.absoluteString))
    }

}

fileprivate extension RequestAction {

    var encoding: String.Encoding {
        guard let encodingStr = attributes["charset"]?.lowercased() else {
            return .utf8
        }
        switch encodingStr {
            case "utf-8": return .utf8
            case "cp1251": return .windowsCP1251
            default: return .utf8
        }
    }

    var requestType: RequestType? {
        guard let typeStr = attributes["type"]?.uppercased(), let type = RequestType(rawValue: typeStr) else {
            return nil
        }
        return type
    }

    func processHeaderParams(context: ContextType) {
        var params = [String: String]()
        headerParams.forEach { (key, value) in
            let calculatedKey = self.valueProcessor.value(value: key, context: context)
            let calculatedValue = self.valueProcessor.value(value: value, context: context)
            params[calculatedKey] = calculatedValue
        }
        if params[HeaderKey.userAgent.rawValue] == nil {
            params[HeaderKey.userAgent.rawValue] = userAgentValue
        }
        if params[HeaderKey.referer.rawValue] == nil, case let VariableType.string(lastOpenedUrl)? = context.variable(name: ContextKey.lastOpenedUrl.rawValue) {
            params[HeaderKey.referer.rawValue] = lastOpenedUrl
        }
        headerParams = params
    }

    func processRequestParams(context: ContextType, data: VariableType?) {
        var params = [String: String]()
        // include hidden params first, they can be overriden by local variables
        if let includeHiddenParams = includeHiddenParams, includeHiddenParams.include == true, let data = includeHiddenParams.tagValue ?? data?.stringValue() {
            let calculatedData = self.valueProcessor.value(value: data, context: context)
            params += hiddenParams(data: calculatedData)
        }
        requestParams.forEach { (key, value) in
            let calculatedKey = self.valueProcessor.value(value: key, context: context)
            let calculatedValue = self.valueProcessor.value(value: value, context: context)
            params[calculatedKey] = calculatedValue
        }
        requestParams = params
    }

    func hiddenParams(data: String) -> [String: String] {
        let regex = try! NSRegularExpression(pattern: "<input[^>]*type=[\"|']hidden[\"|']\\s*([\\s\\S]*?)\\s*>", options: [.caseInsensitive])
        let matches = regex.matches(in: data, options: [], range: NSRange(location: 0, length: data.count))
        let params = matches.reduce([String: String]()) { (params, match) -> [String: String] in
            guard match.numberOfRanges > 1 else {
                return params
            }
            let range = match.range(at: 1)
            var str = (data as NSString).substring(with: range)
            str = str.replacingOccurrences(of: "\n", with: " ")
                .replacingOccurrences(of: "\t", with: " ")
                .replacingOccurrences(of: "\r", with: " ")
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: "'", with: "")
                .replacingOccurrences(of: "  ", with: " ")
            if str.hasSuffix("/") {
                str = String(str[..<str.endIndex])//str.substring(to: str.index(before: str.endIndex))
            }
            str = str.trim
            var name: String?
            var value: String?
            var idStr: String?
            str.components(separatedBy: " ").forEach { param in
                if let equalRange = param.range(of: "=") {
                    let attrName = String(param[..<equalRange.lowerBound])
                    let attrValue = removeQuotes(from: String(param[equalRange.upperBound...]))
                    switch attrName {
                    case "name":
                        name = attrValue
                    case "id":
                        idStr = attrValue
                    case "value":
                        value = attrValue
                    default:
                        break
                    }
                }
            }
            if let value = value, let key = name ?? idStr {
                return params + [key: value]
            } else {
                return params
            }
        }
        return params
    }

    func removeQuotes(from str: String) -> String {
        var str: Substring = Substring(str)
        while str.hasPrefix("\"") {
            str = str[str.index(after: str.startIndex)...]
        }
        while str.hasPrefix("'") {
            str = str[str.index(after: str.startIndex)...]
        }
        while str.hasSuffix("\"") {
            str = str[..<str.endIndex]
        }
        while str.hasSuffix("'") {
            str = str[..<str.endIndex]
        }
        return String(str)
    }

    func requestFinished(with response: DataResponse<String>, context: ContextType, callback: @escaping (VariableType?, Error?) -> ()) {
        var result: VariableType? = nil
        var resultError: Error? = nil
        defer {
            callback(result, resultError)
        }
        if let error = response.error {
            if let code = response.response?.statusCode, needIgnoreStatusCode(code: code) {
                let responseEncoding = encoding
                if let data = response.data, let dataStr = String(data: data, encoding: responseEncoding) {
                    result = .string(dataStr)
                }
            } else {
                resultError = error
            }
        } else {
            if let responseStr = response.value {
                result = .string(responseStr)
            }
        }
    }

    func needIgnoreStatusCode(code: Int) -> Bool {
        guard let codesStr = attributes["ignore"]?.components(separatedBy: "|"), codesStr.map( { Int($0) } ).flatMap( { $0 } ).contains(code) else {
            return false
        }
        return true
    }

    func makeSessionManager(headers: [String: String]) -> Alamofire.SessionManager {
        let configuration = URLSessionConfiguration.default
        var allHeaders = SessionManager.defaultHTTPHeaders
        allHeaders += headers
        configuration.httpAdditionalHeaders = allHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        return SessionManager(configuration: configuration)
    }

    func jsonFromRawString(_ string: String) -> Data? {
        guard let jsonData = string.data(using: .utf8) else { return nil }
        return jsonData
    }

}
