## Firestore export Cloud Function

This module creates the resources necessary for exporting Firestore data for backups and for analytics purposes.

### Resources 

- Cloud Function
    - Application code uses attached service account to:
        - invoke Firestore export jobs + stores exported data in a storage bucket
        - write application data to BiqQuery tables for analytics purposes

-  Storage bucket to store Firestore exports
-  Storage bucket to store Cloud Function source code
-  Cloud Scheduler job and Pub/Sub topic to trigger Cloud Function

### Source Code

[Source Code](../../../../cloudfunctions/db_export/index.js)



