The script runs a Flopsar demo where multiple instances of eCommerce application are allowed.


* To start demo execute:
  ```
  $ demo2.1.sh start N /path/to/license.key
  ```
  where `N` is a number of instances.

* To stop and remove all the created containers execute:
  ```
  $ demo2.1.sh stop N
  ```
  
* To retarget agents execute:
  ```
  $ demo2.1.sh retarget N
  ```

Please note, when you start Flopsar Workstation you must attach agents to the existing configuration manually.

When some agents are not attached to the database, rerun the script with `retarget` argument.

