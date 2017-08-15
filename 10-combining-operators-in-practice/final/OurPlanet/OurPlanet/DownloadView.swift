//
//  DownloadView.swift
//  OurPlanet
//
//  Created by Forrest Zhao on 8/14/17.
//  Copyright © 2017 Florent Pillet. All rights reserved.
//

import Foundation
import UIKit

class DownloadView: UIStackView {

  lazy var progress: UIProgressView = {
    let view = UIProgressView()
    return view
  }()
  
  lazy var label: UILabel = {
    let view = UILabel()
    return view
  }()
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    translatesAutoresizingMaskIntoConstraints = false
    
    axis = .horizontal
    spacing = 0
    distribution = .fillEqually
    
    if let superview = superview {
      backgroundColor = UIColor.white
      
      bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
      leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
      trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
      heightAnchor.constraint(equalToConstant: 38).isActive = true
      
      addArrangedSubview(label)
      label.text = "Downloads"
      label.translatesAutoresizingMaskIntoConstraints = false
      label.backgroundColor = .lightGray
      label.textAlignment = .center
      
      let progressWrap = UIView()
      progressWrap.translatesAutoresizingMaskIntoConstraints = false
      progressWrap.backgroundColor = .lightGray
      progressWrap.addSubview(progress)
      
      progress.leadingAnchor.constraint(equalTo: progressWrap.leadingAnchor).isActive = true
      progress.trailingAnchor.constraint(equalTo: progressWrap.trailingAnchor, constant: -10).isActive = true
      progress.heightAnchor.constraint(equalToConstant: 4).isActive = true
      progress.centerYAnchor.constraint(equalTo: progressWrap.centerYAnchor).isActive = true
      
      addArrangedSubview(label)
      addArrangedSubview(progressWrap)
      
    }
  }

}
