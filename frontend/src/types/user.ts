export interface User {
  id: number
  email: string
  fullName: string
  phone: string
  avatar?: string
  isEmailVerified: boolean
  isActive: boolean
  role: string
  roles: string[]
  permissions: string[]
  createdAt: string
  updatedAt: string
}

export interface UserResponse {
  id: number
  email: string
  fullName: string
  phone: string
  avatar?: string
  isEmailVerified: boolean
  isActive: boolean
  roles: string[]
  permissions: string[]
  createdAt: string
  updatedAt: string
}

export interface JwtResponse {
  accessToken: string
  refreshToken: string
  tokenType: string
  expiresIn: number
  user: UserResponse
}

export interface LoginRequest {
  email: string
  password: string
}

export interface RegisterRequest {
  email: string
  password: string
  fullName: string
  phone: string
  role?: string
}

export interface OtpVerifyRequest {
  email: string
  otp: string
}

export interface ForgotPasswordRequest {
  email: string
}

export interface ResetPasswordRequest {
  email: string
  otp: string
  newPassword: string
  confirmPassword: string
}

export interface ChangePasswordRequest {
  currentPassword: string
  newPassword: string
  confirmPassword: string
}