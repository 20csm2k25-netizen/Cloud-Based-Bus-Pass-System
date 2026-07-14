import Fastify from 'fastify';
import { PrismaClient } from '@prisma/client';
import { PrismaUserRepository } from './repository.js';
import { hashPassword, verifyPassword } from './password.js';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from './jwt.js';

type AuthBody = {
  email?: string;
  password?: string;
  phone?: string;
};

function assertString(value: unknown, field: string): asserts value is string {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(`Missing or invalid ${field}`);
  }
}

export function buildServer() {
  const app = Fastify({ logger: true });
  const prisma = new PrismaClient();
  const users = new PrismaUserRepository(prisma);

  app.get('/healthz', async () => ({ ok: true }));

  app.post<{ Body: AuthBody }>('/auth/signup', async (request, reply) => {
    try {
      const email = request.body?.email;
      const password = request.body?.password;
      const phone = request.body?.phone;
      assertString(email, 'email');
      assertString(password, 'password');

      const normalizedEmail = email.toLowerCase();
      const existingUser = await users.findByEmail(normalizedEmail);
      if (existingUser) {
        return reply.code(409).send({ error: 'Email already registered' });
      }

      const passwordHash = await hashPassword(password);
      const createdUser = await users.createUser({
        email: normalizedEmail,
        phone,
        passwordHash,
      });

      const claims = {
        sub: createdUser.id,
        email: createdUser.email,
        role: createdUser.role,
      } as const;

      return reply.code(201).send({
        user: {
          id: createdUser.id,
          email: createdUser.email,
          phone: createdUser.phone,
          role: createdUser.role,
        },
        accessToken: signAccessToken(claims),
        refreshToken: signRefreshToken(claims),
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Signup failed';
      return reply.code(400).send({ error: message });
    }
  });

  app.post<{ Body: AuthBody }>('/auth/login', async (request, reply) => {
    try {
      const email = request.body?.email;
      const password = request.body?.password;
      assertString(email, 'email');
      assertString(password, 'password');

      const user = await users.findByEmail(email.toLowerCase());
      if (!user) {
        return reply.code(401).send({ error: 'Invalid credentials' });
      }

      const passwordMatches = await verifyPassword(password, user.passwordHash);
      if (!passwordMatches) {
        return reply.code(401).send({ error: 'Invalid credentials' });
      }

      const claims = {
        sub: user.id,
        email: user.email,
        role: user.role,
      } as const;

      return reply.send({
        user: {
          id: user.id,
          email: user.email,
          phone: user.phone,
          role: user.role,
        },
        accessToken: signAccessToken(claims),
        refreshToken: signRefreshToken(claims),
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Login failed';
      return reply.code(400).send({ error: message });
    }
  });

  app.post<{ Body: { refreshToken?: string } }>('/auth/refresh', async (request, reply) => {
    try {
      const refreshToken = request.body?.refreshToken;
      assertString(refreshToken, 'refreshToken');
      const claims = verifyRefreshToken(refreshToken);
      const refreshedClaims = {
        sub: claims.sub,
        email: claims.email,
        role: claims.role,
      } as const;

      return reply.send({
        accessToken: signAccessToken(refreshedClaims),
        refreshToken: signRefreshToken(refreshedClaims),
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Refresh failed';
      return reply.code(401).send({ error: message });
    }
  });

  return app;
}

export async function startAuthService() {
  const app = buildServer();
  const port = Number(process.env.APP_PORT ?? 3001);

  await app.listen({ port, host: '0.0.0.0' });
  return app;
}import Fastify from 'fastify';

const app = Fastify({ logger: true });

app.get('/healthz', async () => ({ ok: true }));

app.post('/auth/signup', async () => {
  return { status: 'not-implemented' };
});

app.post('/auth/login', async () => {
  return { status: 'not-implemented' };
});

app.post('/auth/refresh', async () => {
  return { status: 'not-implemented' };
});

const port = Number(process.env.APP_PORT ?? 3001);

app.listen({ port, host: '0.0.0.0' }).catch((error) => {
  app.log.error(error);
  process.exit(1);
});
