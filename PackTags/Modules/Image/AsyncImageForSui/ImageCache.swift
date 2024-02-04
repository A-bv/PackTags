//
//  ImageCache.swift
//  AsyncImage
//
// 

import UIKit

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}
