import Foundation
import SwiftyJSON
import WCDBSwift

public class UnsplashUser: ColumnJSONCodable {
    var id: String?
    var userName: String?
    var name: String?
    var links: ProfileUrl?

    var homeUrl: String? {
        get {
            return links?.html
        }
    }
}

public class ProfileUrl: ColumnJSONCodable {
    var selfUrl: String?
    var html: String?
    var photos: String?
    var likes: String?
    var portfolio: String?
}