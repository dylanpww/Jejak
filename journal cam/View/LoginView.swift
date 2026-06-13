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
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.primary)

                        Text("Journal Cam")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)

                        Text("Your daily selfie journal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 48)

                    // Form
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .foregroundStyle(.primary)
                            }
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            HStack {
                                Image(systemName: "lock")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                SecureField("Password", text: $password)
                                    .foregroundStyle(.primary)
                            }
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 24)

                        if let error = errorMessage {
                            Text(error)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }

                        Button {
                            Task { await signIn() }
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                email.isEmpty || password.isEmpty
                                ? Color(.systemGray3)
                                : Color.accentColor
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding(.horizontal, 24)
                    }

                    Spacer()

                    NavigationLink(destination: RegisterView(authService: authService)) {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundStyle(.secondary)
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }
                        .font(.subheadline)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
