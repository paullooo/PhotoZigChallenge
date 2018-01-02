//
//  BaseService.swift
//  PhotoZigChallenge
//
//  Created by Paulo on 01/01/18.
//  Copyright © 2018 Paulo. All rights reserved.
//

import SwiftyJSON
import Alamofire

enum APIError {
    case noInternet, serverError, notAuthorized, canceled, conflict, httpError(string: String), other
    
    var description: String {
        switch self {
        case .noInternet: return "Sem acesso a internet"
        case .serverError: return "Erro internno do servidor"
        case .notAuthorized: return "Usuário não autorizado"
        case .canceled: return "Request cancelado"
        case .conflict: return "Conflito no servidor"
        case .httpError(let mensagem): return mensagem.isEmpty ? "Tente novamente mais tarde" : mensagem
        case .other: return "Tente novamente mais tarde"
        }
    }
}

class BaseService {
    
    private func getErrorType(statusCode: Int, data: Data?)-> APIError {
        switch statusCode {
        case 500...599:
            return APIError.serverError
        case 400,403:
            return data != nil ? APIError.httpError(string: try! JSON(data: data!)["message"].stringValue) : APIError.other
        case 409:
            return APIError.conflict
        case 401:
            return APIError.notAuthorized
        case -999:
            return APIError.canceled
        case -1009:
            return APIError.noInternet
        default:
            return APIError.other
        }
    }
    
    private func getStatusCode<T: Any>(response: DataResponse<T>) -> Int {
        var statusCode = 0
        if let httpResponse = response.response {
            statusCode = httpResponse.statusCode
        } else {
            if let urlError = response.result.error as? URLError {
                statusCode = urlError.errorCode
            }
        }
        return statusCode
    }
    
    func getError<T: Any>(response: DataResponse<T>) -> Error {
        let statusCode = self.getStatusCode(response: response)
        let errorType = self.getErrorType(statusCode: statusCode, data: response.data)
        return NSError(domain: "com.devpaulopereira", code: statusCode, userInfo: ["type":errorType])
    }
}
