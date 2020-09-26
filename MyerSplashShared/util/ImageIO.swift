//
// Created by MAC on 2020/1/6.
// Copyright (c) 2020 juniper. All rights reserved.
//

import Foundation
import Nuke

public class ImageIO {
    private static let TAG = "ImageIO"
    
    public static func isImageCached(_ url: String)-> Bool {
        guard let uri = URL(string: url) else {
            return false
        }
        
        let request = ImageRequest(url: uri)
        
        let diskCached = DataLoader.sharedUrlCache.cachedResponse(for: request.urlRequest) != nil
        let memoryCached = Nuke.ImageCache.shared[request] != nil
        
        print("disk cached: \(diskCached), memory cached: \(memoryCached)")
        return diskCached || memoryCached
    }
    
    public static func getCachedImage(_ url: String?)-> UIImage? {
        if url == nil {
            return nil
        }
        
        guard let uri = URL(string: url!) else {
            return nil
        }
        let request = ImageRequest(url: uri)
        let image = Nuke.ImageCache.shared[request]
        
        if image != nil {
            return image
        }
        
        let data = DataLoader.sharedUrlCache.cachedResponse(for: request.urlRequest)?.data
        
        if data != nil {
            return UIImage(data: data!)
        }
        
        return nil
    }
    
    public static func getDiskCacheSizeBytes()-> Int {
        return DataLoader.sharedUrlCache.currentDiskUsage
    }
    
    public static func getFormattedDiskCacheSize()-> String {
        return String(format: "%.2fMB", DataLoader.sharedUrlCache.currentDiskUsage.toCGFloat() / 1024.0 / 1024.0)
    }
    
    public static func clearCaches(includingDownloads: Bool) {
        DataLoader.sharedUrlCache.removeAllCachedResponses()
        
        if includingDownloads {
            clearDownloadFiles()
        }
    }
    
    public static func clearDownloadFiles() {
        DispatchQueue.global().async {
            do {
                var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                url.appendPathComponent(DownloadManager.DOWNLOAD_DIR)
                try FileManager.default.removeItem(at: url)
            } catch let e {
                Log.warn(tag: ImageIO.TAG, "error on clear disk: \(e.localizedDescription)")
            }
        }
    }
    
    public static func loadImage(url: String,
                          intoView: ImageDisplayingView,
                          fade: Bool = true,
                          completion: ImageTask.Completion? = nil) {
        let request = ImageRequest(url: URL(string: url)!)
        loadImage(request: request, intoView: intoView, fade: fade, completion: completion)
    }
    
    public static func loadImage(request: ImageRequest,
                          intoView: ImageDisplayingView,
                          fade: Bool = true,
                          completion: ImageTask.Completion? = nil) {
        let transition = fade ? ImageLoadingOptions.Transition.fadeIn(duration: 0.3) : nil
                
        Nuke.loadImage(with: request,
                       options: ImageLoadingOptions(
                        placeholder: nil,
                            transition: transition,
                            failureImage: nil,
                            failureImageTransition: nil,
                            contentModes: .init(success: .scaleAspectFill, failure: .center, placeholder: .center)),
                       into: intoView, progress: nil, completion: completion)
    }
    
    public static func getImageSize(at url: URL) -> CGSize {
        let exist = FileManager.default.fileExists(atPath: url.path)
        if !exist {
            return CGSize.zero
        }
        
        let image = UIImage(contentsOfFile: url.path)
        
        return image?.size ?? CGSize.zero
    }
    
    public static func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
        let exist = FileManager.default.fileExists(atPath: url.path)
        
        Log.info(tag: ImageIO.TAG, "resizedImage check exists, \(exist) at \(url.path)")

        guard let image = UIImage(contentsOfFile: url.path) else {
            Log.info(tag: ImageIO.TAG, "resizedImage nil image")
            return nil
        }

        Log.info(tag: ImageIO.TAG, "resizedImage about to draw in \(size)")
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
