import jwt from 'jsonwebtoken';
import { authConfig } from './config.js';

export type AuthTokenClaims = {
  sub: string;
  email: string;
  role: 'rider' | 'operator_admin' | 'platform_admin';
};

export function signAccessToken(claims: AuthTokenClaims): string {
  return jwt.sign(claims, authConfig.accessTokenSecret, { expiresIn: authConfig.accessTokenTtl });
}

export function signRefreshToken(claims: AuthTokenClaims): string {
  return jwt.sign(claims, authConfig.refreshTokenSecret, { expiresIn: authConfig.refreshTokenTtl });
}

export function verifyRefreshToken(token: string): AuthTokenClaims {
  return jwt.verify(token, authConfig.refreshTokenSecret) as AuthTokenClaims;
}