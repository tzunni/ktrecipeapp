//
//  LoginView.swift
//  ktrecipeapp
//
//  Created by csuftitan on 4/27/25.
//

import SwiftUI

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start at bottom-left
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        // Line up to a starting point for the wave
        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.4))
        
        // Draw a curve
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.4),
            control: CGPoint(x: rect.width / 2, y: rect.height * 0.2)
        )
        
        // Line down to bottom-right
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}

struct LoginView: View {
    var body: some View {
        ZStack {
            Color(.systemGray5).ignoresSafeArea()
            
            // Blue Wave behind everything
            VStack {
                WaveShape().fill(Color.blue).frame(height: UIScreen.main.bounds.height * 0.7).offset(y: 50) // Increased height for more coverage.ignoresSafeArea(edges:.bottom)
            }.frame(maxHeight:.infinity, alignment:.bottom).allowsHitTesting(false)
            
            VStack {
                Spacer()
                
                // Logo and App Title
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife.circle.fill").resizable().frame(width: 100, height: 100).foregroundColor(.blue)
                    
                    Text("K&T").font(.largeTitle).fontWeight(.bold).foregroundColor(.blue)
                    
                    Text("RECIPE APP").font(.title3).foregroundColor(.blue)
                }
                
                Spacer()
                
                // Login Card
                VStack(spacing: 20) {
                    // Email field
                    HStack {
                        Image(systemName: "envelope").foregroundColor(.gray)
                        TextField("Email", text:.constant("")).autocapitalization(.none)
                    }.padding().background(Color(.systemGray6)).cornerRadius(10)
                    
                    // Password field
                    HStack {
                        Image(systemName: "lock").foregroundColor(.gray)
                        SecureField("Password", text:.constant(""))
                    }.padding().background(Color(.systemGray6)).cornerRadius(10)
                    
                    // Remember Me + Forgot Password
                    HStack {
                        Toggle(isOn:.constant(false)) {
                            Text("Remember Me").font(.footnote)
                        }.toggleStyle(CheckboxToggleStyle())
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Forgot Password?").font(.footnote).foregroundColor(.blue)
                        }
                    }
                    
                    // Login button
                    Button(action: {}) {
                        Text("Login").foregroundColor(.white).frame(maxWidth:.infinity).padding().background(Color.blue).cornerRadius(10)
                    }
                    
                    // Create account link
                    HStack {
                        Text("Don't have an account?").font(.footnote)
                        Button(action: {}) {
                            Text("Create an account").font(.footnote).foregroundColor(.blue)
                        }
                    }.padding(.top, 10)
                    
                }.padding(30).background(Color.white).cornerRadius(30).shadow(radius: 10).padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square").foregroundColor(.blue)
                configuration.label
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
