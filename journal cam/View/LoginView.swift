//
//  LoginView.swift
//  journal cam
//
//  Created by Dylan on 07/06/26.
//

import SwiftUI

struct LoginView: View {
    let authService: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "camera.fill")
                .font(.system(size: 64))
                .foregroundStyle(.primary)

            Text("Journal Cam")
                .font(.largeTitle.bold())

            Text(isLogin ? "Welcome back" : "Create your account")
                .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)

            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await submit() }
            } label: {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(isLogin ? "Sign In" : "Sign Up")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.primary)
                .foregroundStyle(.background)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .padding(.horizontal)

            Button {
                isLogin.toggle()
                errorMessage = nil
            } label: {
                Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 32)
        }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil
        do {
            if isLogin {
                try await authService.signIn(email: email, password: password)
            } else {
                try await authService.signUp(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
