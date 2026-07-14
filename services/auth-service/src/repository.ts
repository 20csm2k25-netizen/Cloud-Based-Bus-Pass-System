import { PrismaClient, User, UserRole } from '@prisma/client';

export type CreateUserInput = {
  email: string;
  phone?: string;
  passwordHash: string;
  role?: UserRole;
};

export interface UserRepository {
  findByEmail(email: string): Promise<User | null>;
  createUser(input: CreateUserInput): Promise<User>;
}

export class PrismaUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { email } });
  }

  createUser(input: CreateUserInput): Promise<User> {
    return this.prisma.user.create({
      data: {
        email: input.email,
        phone: input.phone,
        passwordHash: input.passwordHash,
        role: input.role ?? 'rider',
      },
    });
  }
}