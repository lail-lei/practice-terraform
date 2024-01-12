// Copied pasted from ingka-group-digital/csrs-sfso-backend/chron/firebase-import-export
const firestore = require('@google-cloud/firestore');
const { BigQuery } = require('@google-cloud/bigquery');
const client = new firestore.v1.FirestoreAdminClient();

const Constants = {
  STORAGE_BUCKET: process.env.STORAGE_BUCKET,
  FIREBASE_TABLES: ['Orders', 'WebAppUser'],
  BQ_DATASET_ID: 'firestore_app_data',
  PROJECT_ID: process.env.GCLOUD_PROJECT
};

const threadSleep = (ms) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

exports.firestoreExport = () => {
    const databaseName = client.databasePath(Constants.PROJECT_ID, '(default)');

    return client.exportDocuments({
      name: databaseName,
      outputUriPrefix: Constants.STORAGE_BUCKET,
      collectionIds: Constants.FIREBASE_TABLES
    })
      .then(async responses => {
        let tables;
        let outputUriPrefix = '';        
        const primaryResponse = responses[0];

        for (x = 0; x < 10; x++) {
          await threadSleep(6 * 1000);

          const checkProgress = await client.checkExportDocumentsProgress(primaryResponse.name);

          const parsedCheckProgress = JSON.parse(
            JSON.stringify(checkProgress)
          );

          const done = parsedCheckProgress.done;

          if (done) {
            console.info(`Backup operation complete.`);
            outputUriPrefix = primaryResponse.metadata.outputUriPrefix;
            tables = primaryResponse.metadata.collectionIds;
            break;
          }

          console.warn(`Operation not complete after ${(x + 1) * 6} seconds, sleeping...`);
        }

        // console.debug('Out of loop, export should be done, primary response:');
        // console.debug(JSON.stringify(primaryResponse));

        const bqClient = new BigQuery();

        let index = 0;
        while (index < tables.length) {
          const table = tables[index];
          console.info(`Importing table '${table}'...`);

          const sourceUri = `${outputUriPrefix}/all_namespaces/kind_${table}/all_namespaces_kind_${table}.export_metadata`;
          const options = {
            jobReference: {
              projectId: Constants.PROJECT_ID,
              jobId: `${table}-${new Date().toISOString()}`,
              location: "EU",
            },
            configuration: {
              load: {
                destinationTable: {
                  tableId: table,
                  datasetId: Constants.BQ_DATASET_ID,
                  projectId: Constants.PROJECT_ID,
                },
                sourceFormat: "DATASTORE_BACKUP",
                writeDisposition: "WRITE_TRUNCATE",
                sourceUris: [sourceUri],
              },
            },
          };

          console.debug(`Creating job: '${options.jobReference.jobId}'...`);
          bqClient.createJob(options);
          console.info(`Import job submitted, not awaiting response.`);
          index++;
        }

        console.info('Import / Export process complete.');
      })
      .catch(err => {
        console.error(err);
        throw new Error('Import / Export operation failed');
      });
  };