module.exports =
  # create bucket
  "newStorageBucket.name":
    locator: "id"
    value: "bucket-name"
  "newStorageBucket.add":
    locator: "css"
    value: "#create-bucket-form button.create-bucket"

  # bucket list
  "storageBucket.name": (bucketName) ->
    locator: "css"
    value: ".storage-bucket[data-bucket-name=#{bucketName}] span.bucket-name"

  # delete bucket
  "storageBucket.delete": (bucketName) ->
    locator: "css"
    value: ".storage-bucket[data-bucket-name=#{bucketName}] .delete-bucket"
  "storageBucket.delete.confirm": (bucketName) ->
    locator: "css"
    value: ".storage-bucket[data-bucket-name=#{bucketName}] .delete-bucket-confirm"

  # copy bucket
  "storageBucket.copy": (bucketName) ->
    locator: "css"
    value: ".storage-bucket[data-bucket-name=#{bucketName}] .copy-bucket"
  "storageBucket.copy.name": (bucketName) ->
    locator: "css"
    value: ".storage-bucket[data-bucket-name=#{bucketName}] .copy-bucket-form .bucket-name"
  "storageBucket.copy.submit": (bucketName) ->
    locator: "css"
    value: ".storage-bucket[data-bucket-name=#{bucketName}] .copy-bucket-submit"
