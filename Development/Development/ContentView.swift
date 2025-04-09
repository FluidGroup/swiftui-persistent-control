//
//  ContentView.swift
//  Development
//
//  Created by Muukii on 2025/03/21.
//

import StorybookKit
import SwiftUI
import SwiftUIPersistentControl

struct ContentView: View {
  
  @Namespace private var namespace
  @State var isCompact: Bool = true
  
  var body: some View {
    Container(
      isCompact: $isCompact,
      namespace: namespace,
      compactContent: {
        CompactContentView(namespace: namespace)
      },
      detailContent: {
        DetailContentView(namespace: namespace)
      },
      detailBackground: {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .fill(Color.yellow)
      }
    )
//    Storybook()
  }
}
private struct _Book: View {
  
  @Namespace private var namespace
  @State var isCompact: Bool = true
  
  var body: some View {
    Container(
      isCompact: $isCompact,
      namespace: namespace,
      compactContent: {
        CompactContentView(namespace: namespace)
      },
      detailContent: {
        DetailContentView(namespace: namespace)
      },
      detailBackground: {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .fill(Color.yellow)
      }
    )
  }
}

private struct CompactContentView: View {
  
  let namespace: Namespace.ID
  
  var body: some View {
    HStack {
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(Color.red)
        .matchedGeometryEffect(id: "art", in: namespace)
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 60)
      Text("コンテンツ")
        .font(.headline)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .padding()
  }
}

private struct DetailContentView: View {
  
  enum Mode {
    case current
    case list
  }
  
  let namespace: Namespace.ID
  @State private var mode: Mode = .current
  @State var safeAreaInsets: EdgeInsets = .init()
  
  var body: some View {
    ZStack {
      
      VStack(spacing: 0) {
        HStack {
          Picker("表示モード", selection: $mode) {
            Text("現在").tag(Mode.current)
            Text("リスト").tag(Mode.list)
          }
          .pickerStyle(.segmented)
          .padding()
        }
        
        switch mode {
        case .current:
          VStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
              .fill(Color.primary.secondary)
              .aspectRatio(1, contentMode: .fit)
              .matchedGeometryEffect(id: "art", in: namespace)
              .padding(60)
            Text("コンテンツ")
              .foregroundColor(.white)
              .font(.headline)
              .matchedGeometryEffect(id: "text", in: namespace)
            Spacer()
          }
        case .list:
          ScrollView {
            LazyVStack(spacing: 12) {
              ForEach(0..<20) { i in
                HStack {
                  RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primary)
                    .frame(width: 60, height: 60)
                  VStack(alignment: .leading) {
                    Text("コンテンツ \(i + 1)")
                      .font(.headline)
                    Text("説明文がここに入ります")
                      .font(.subheadline)
                      .foregroundColor(.secondary)
                  }
                  Spacer()
                }
                .padding(.horizontal)
              }
            }
            .padding(.vertical)
          }
        }
      }
    }
    .onGeometryChange(
      for: EdgeInsets.self, of: \.safeAreaInsets,
      action: {
        self.safeAreaInsets = $0
      }
    )
    .backgroundStyle(Color.yellow)
  }
}

#Preview {
  ContentView()
}
