export const env = {
  nodeEnv: process.env.NODE_ENV ?? 'development',
  appPort: Number(process.env.APP_PORT ?? 3000),
};
