import { MongoMemoryServer } from 'mongodb-memory-server';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function start() {
  const dbPath = path.resolve(__dirname, '../.mongodb_data');
  if (!fs.existsSync(dbPath)) {
    fs.mkdirSync(dbPath, { recursive: true });
  }

  console.log('📦 Starting persistent local MongoDB on port 27017...');
  const mongod = await MongoMemoryServer.create({
    instance: {
      port: 27017,
      dbName: 'only_dev',
      dbPath,
      storageEngine: 'wiredTiger',
    },
  });

  console.log('========================================================');
  console.log(`✅ Local MongoDB is running at: ${mongod.getUri()}`);
  console.log(`📁 Data directory: ${dbPath}`);
  console.log('========================================================');
  console.log('Press Ctrl+C to stop the local database.');

  process.on('SIGINT', async () => {
    console.log('\nStopping local MongoDB...');
    await mongod.stop();
    process.exit(0);
  });

  process.on('SIGTERM', async () => {
    await mongod.stop();
    process.exit(0);
  });
}

start();

