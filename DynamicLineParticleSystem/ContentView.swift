//
//  ContentView.swift
//  DynamicLineParticleSystem
//
//  Created by Harry Liddell on 16/11/2025.
//

import SwiftUI
import Combine

struct Particle {
    var position: CGPoint
    var velocity: CGVector
    var angle: Double
    var length: CGFloat
}

struct ContentView: View {
    
    @State private var particles: [Particle] = []
    
    private let particleCount = 150
    private let connectionDistance: CGFloat = 100
    private let timer = Timer.publish(every: 1/30, on: .main, in: .common).autoconnect()
    private let color = UIColor(named: "green")!
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Canvas { context, size in
                    for i in 0..<particles.count {
                        for j in (i + 1)..<particles.count {
                            let dx = particles[i].position.x - particles[j].position.x
                            let dy = particles[i].position.y - particles[j].position.y
                            let distance = sqrt(dx * dx + dy * dy)
                            
                            if distance < connectionDistance {
                                
                                let opacity = 1.0 - (distance / connectionDistance)
                                var connectionPath = Path()
                                connectionPath.move(to: particles[i].position)
                                connectionPath.addLine(to: particles[j].position)
                                context.stroke(
                                    connectionPath,
                                    with: .color(Color(uiColor: color).opacity(opacity)),
                                    lineWidth: 0.5
                                )
                            }
                        }
                    }
                    
                    for particle in particles {
                        var particlePath = Path()
                        let halfLength = particle.length / 2
                        
                        let dx = cos(particle.angle) * halfLength
                        let dy = sin(particle.angle) * halfLength
                        
                        let startPoint = CGPoint(
                            x: particle.position.x - dx,
                            y: particle.position.y - dy
                        )
                        
                        let endPoint = CGPoint(
                            x: particle.position.x + dx,
                            y: particle.position.y + dy
                        )
                        
                        particlePath.move(to: startPoint)
                        particlePath.addLine(to: endPoint)
                        
                        context.stroke(
                            particlePath,
                            with: .color(Color(uiColor: color)),
                            lineWidth: 1
                        )
                    }
                }
                .background(.white)
                .onAppear {
                    particles = (0..<particleCount).map { _ in
                        Particle(
                            position: CGPoint(
                                x: CGFloat.random(in: 0...geo.size.width),
                                y: CGFloat.random(in: 0...geo.size.height)
                            ),
                            velocity: CGVector(
                                dx: CGFloat.random(in: -0.5...0.5),
                                dy: CGFloat.random(in: -0.5...0.5)
                            ),
                            angle: Double.random(
                                in: 0...(2 * Double.pi)
                            ),
                            length: CGFloat.random(
                                in: 10...30
                            )
                        )
                    }
                }
                .onReceive(timer) { _ in
                    for index in particles.indices {
                        particles[index].position.x += particles[index].velocity.dx
                        particles[index].position.y += particles[index].velocity.dy
                        
                        if particles[index].position.x < 0 {
                            particles[index].position.x += geo.size.width
                        } else if particles[index].position.x > geo.size.width {
                            particles[index].position.x -= geo.size.width
                        }
                        
                        if particles[index].position.y < 0 {
                            particles[index].position.y += geo.size.height
                        } else if particles[index].position.y > geo.size.height {
                            particles[index].position.y -= geo.size.height
                        }
                        
                        particles[index].angle += 0.02
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
