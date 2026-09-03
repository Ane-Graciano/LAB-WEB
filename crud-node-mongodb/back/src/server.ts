import { app } from "./app";

import {
  connectDatabase,
} from "./config/database";

import { env } from "./config/env";

async function bootstrap() {

  try {

    await connectDatabase();

    app.listen(
      env.port,
      () => {

        console.log(
          `✓ API rodando em http://localhost:${env.port}`
        );

      }
    );

  } catch (error) {

    console.error(
      "Erro ao iniciar servidor:",
      error
    );

    process.exit(1);
  }
}

bootstrap();
