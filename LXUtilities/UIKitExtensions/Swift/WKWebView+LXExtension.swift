//
//  WKWebView+LXExtension.swift
//  WuLianWu
//
//  Created by 从今以后 on 2017/11/9.
//  Copyright © 2017年 冠霖环如. All rights reserved.
//

extension Swifty where Base: WKWebView {
	
	func loadRequest(withURLString string: String) throws {
		guard let url = URL(string: string) else {
			throw URLError(.badURL)
		}
		base.load(URLRequest(url: url))
	}
}
