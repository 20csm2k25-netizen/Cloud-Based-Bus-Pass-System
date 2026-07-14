import { startAuthService } from './server.js';

startAuthService().catch((error) => {
	console.error(error);
	process.exit(1);
});
