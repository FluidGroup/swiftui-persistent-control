import SwiftUI
internal import SwiftUIScrollViewInteroperableDragGesture

private struct Container<
  CompactContent: View,
  DetailContent: View,
  DetailBackground: View
>: View {
  
  @State private var isCompact = true
  @Namespace private var namespace
  @State private var offset: CGFloat = 0
  
  private let compactContent: CompactContent
  private let detailContent: DetailContent
  private let detailBackground: DetailBackground
  
  init(
    @ViewBuilder compactContent: () -> CompactContent,
    @ViewBuilder detailContent: () -> DetailContent,
    @ViewBuilder detailBackground: () -> DetailBackground
  ) {
    self.compactContent = compactContent()
    self.detailContent = detailContent()
    self.detailBackground = detailBackground()
  }
  
  var body: some View {
    ZStack {
      VStack {
        if isCompact {
          Spacer()
          CompactContainer(
            namespace: namespace,
            onActivate: {              
              withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                offset = 0
                isCompact.toggle()
              }
            }
          ) {
            compactContent
          }
          .padding(.horizontal)
          
        } else {
          DetailContainer(
            namespace: namespace, offset: $offset,
            onDeactivate: {
              withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                isCompact = true
              }
            },
            content: {
              detailContent
            }, background: {
              detailBackground
            }
          )
          
        }
      }
    }
  }
  
  struct CompactContainer<Content: View>: View {
    
    let namespace: Namespace.ID
    let content: Content
    
    @State private var isPressing: Bool = false
    private let onActivate: () -> Void
    
    init(
      namespace: Namespace.ID,
      onActivate: @escaping () -> Void,
      @ViewBuilder content: () -> Content
    ) {
      self.namespace = namespace
      self.onActivate = onActivate
      self.content = content()
    }
    
    var body: some View {
      
      content
        .background(
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.background)
            .matchedGeometryEffect(id: "frame", in: namespace)
            .shadow(
              color: .init(white: 0, opacity: 0.2),
              radius: 10
            )
        )
        .frame(height: 60)
        .animation(
          .bouncy,
          body: { view in
            view
              .scaleEffect(isPressing ? 0.95 : 1)
          }
        )
        ._onButtonGesture(
          pressing: { isPressing in
            self.isPressing = isPressing
          },
          perform: {
            onActivate()
          }
        )
      
    }
  }
  
  struct DetailContainer<Content: View, Background: View>: View {
    
    let namespace: Namespace.ID
    let content: Content
    @Binding var offset: CGFloat
    private let onDeactivate: () -> Void
    @State var safeAreaInsets: EdgeInsets = .init()
    private let background: Background
    
    init(
      namespace: Namespace.ID,
      offset: Binding<CGFloat>,
      onDeactivate: @escaping () -> Void,
      @ViewBuilder content: () -> Content,
      @ViewBuilder background: () -> Background
    ) {
      self.namespace = namespace
      self.onDeactivate = onDeactivate
      self._offset = offset
      self.content = content()
      self.background = background()
    }
    
    var body: some View {
      
      ZStack {
        ZStack(alignment: .top) {   
          background
            .padding(
              EdgeInsets(
                top: -safeAreaInsets.top,
                leading: -safeAreaInsets.leading,
                bottom: -safeAreaInsets.bottom,
                trailing: -safeAreaInsets.trailing
              )
            )
          content
        }
        .matchedGeometryEffect(id: "frame", in: namespace)
        .mask(
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .padding(
              EdgeInsets(
                top: -safeAreaInsets.top,
                leading: -safeAreaInsets.leading,
                bottom: -safeAreaInsets.bottom,
                trailing: -safeAreaInsets.trailing
              )
            )
        )
        .modifier(
          _Modifier(
            offset: $offset,
            onDismiss: onDeactivate
          )
        )
      }
      .onGeometryChange(
        for: EdgeInsets.self, of: \.safeAreaInsets,
        action: {
          self.safeAreaInsets = $0
        })
      
    }
  }
  
  private struct _Modifier: ViewModifier {
    
    @Binding private var offset: CGFloat
    var onDismiss: () -> Void
    
    @State private var isScrollLockEnabled = false
    
    private let dismissThreshold: CGFloat = 200
    private let velocityThreshold: CGFloat = 300
    
    init(
      offset: Binding<CGFloat>,
      onDismiss: @escaping () -> Void
    ) {
      self._offset = offset
      self.onDismiss = onDismiss
    }
    
    func body(content: Content) -> some View {
      content
        .offset(y: offset)
        .gesture(
          ScrollViewInteroperableDragGesture(
            configuration: .init(
              ignoresScrollView: false,
              targetEdges: .top,
              sticksToEdges: false
            ),
            isScrollLockEnabled: $isScrollLockEnabled,
            coordinateSpaceInDragging: .global,
            onChange: { value in
              // for better fps
              withAnimation(.snappy(duration: 0.05)) {
                offset = value.translation.height
                
                if value.translation.height > 0 {                
                  isScrollLockEnabled = true
                } else {
                  isScrollLockEnabled = false
                  offset = 0
                }
                
              }
              
            },
            onEnd: { value in
              let velocity = value.velocity.height
              
              if velocity > velocityThreshold || offset > dismissThreshold {
                let distance = UIScreen.main.bounds.height - offset
                let initialVelocity = Double(velocity / distance)
                withAnimation(.interpolatingSpring(initialVelocity: initialVelocity)) {
                  offset = UIScreen.main.bounds.height
                }
                onDismiss()
              } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                  offset = 0
                }
              }
            }
          )
        )
    }
  }
}

private struct _Book: View {
  
  @Namespace private var namespace
  
  var body: some View {
    Container(
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
        .aspectRatio(1, contentMode: .fit)
        .matchedGeometryEffect(id: "art", in: namespace)
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
  @State private var mode: Mode = .list
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

#Preview("ContextSheet") {
  _Book()
}
