##' @importFrom R6 R6Class
rleveldb <- function(name, create_if_missing = NULL,
                            error_if_exists = NULL,
                            paranoid_checks = NULL,
                            write_buffer_size = NULL,
                            max_open_files = NULL,
                            cache_capacity = NULL,
                            block_size = NULL,
                            use_compression = NULL,
                            bloom_filter_bits_per_key = NULL) {
  R6_rleveldb$new(name, create_if_missing, error_if_exists,
                  paranoid_checks, write_buffer_size, max_open_files,
                  cache_capacity, block_size, use_compression,
                  bloom_filter_bits_per_key)
}

R6_rleveldb <- R6::R6Class(
  "rleveldb",
  public = list(
    db = NULL,
    initialize = function(name, ...) {
      self$db <- leveldb_connect(name, ...)
    },
    property = function(name, error_if_missing = FALSE) {
      leveldb_property(self$db, name, error_if_missing)
    },
    get = function(key, force_raw, error_if_missing = FALSE,
                   readoptions = NULL) {
      leveldb_get(self$db, key, force_raw, error_if_missing, readoptions)
    },
    put = function(key, value, writeoptions = NULL) {
      leveldb_get(self$db, key, value, writeoptions)
    },
    delete = function(key, writeoptions = NULL) {
      leveldb_delete(self$db, key, writeoptions)
    },
    exists = function(key, readoptions = NULL) {
      leveldb_exists(self$db, key, readoptions)
    },
    keys = function(readoptions = NULL) {
      leveldb_keys(self$db, readoptions)
    },
    keys_len = function(readoptions = NULL) {
      leveldb_keys_len(self$db, readoptions)
    },
    iterator = function(readoptions = NULL) {
      R6_leveldb_iterator$new(self$db, readoptions)
    },
    writebatch = function() {
      R6_leveldb_writebatch$new(self$db)
    },
    snapshot = function() {
      leveldb_snapshot(self$db)
    },
    approximate_sizes = function(start, limit) {
      leveldb_approximate_sizes(self$db, start, limit)
    },
    compact_range = function(start, limit) {
      leveldb_compact_range(self$db, start, limit)
    }
  ))

R6_leveldb_iterator <- R6::R6Class(
  "rleveldb_iterator",
  public = list(
    it = NULL,
    initialize = function(db, readoptions) {
      self$it <- leveldb_iterator(db, readoptions)
    },
    valid = function() {
      leveldb_iter_valid(self$it)
    },
    seek_to_first = function() {
      leveldb_iter_seek_to_first(self$it)
    },
    seek_to_last = function() {
      leveldb_iter_seek_to_last(self$it)
    },
    seek = function(key) {
      leveldb_iter_seek(self$it, key)
    },
    next_ = function() { # TODO: needs a better name -- 'next' is reserved
      leveldb_iter_next(self$it)
    },
    prev = function() {
      leveldb_iter_prev(self$it)
    },
    key = function(force_raw = FALSE, error_if_invalid = FALSE) {
      leveldb_iter_key(self$id, force_raw, error_if_invalid)
    },
    value = function(force_raw = FALSE, error_if_invalid = FALSE) {
      leveldb_iter_value(self$id, force_raw, error_if_invalid)
    }
  ))

R6_leveldb_writebatch <- R6::R6Class(
  "rleveldb_writebatch",
  public = list(
    ptr = NULL,
    db = NULL,

    initialize = function(db) {
      self$db <- db
      self$ptr <- leveldb_writebatch_create()
    },
    clear = function() {
      leveldb_writebatch_clear(self$ptr)
      invisible(self)
    },
    put = function(key, value) {
      leveldb_writebatch_put(self$ptr, key, value)
      invisible(self)
    },
    delete = function(key) {
      leveldb_writebatch_delete(self$ptr, key)
      invisible(self)
    },
    write = function(writeoptions = NULL) {
      leveldb_write(self$db, self$ptr, writeoptions)
    }
  ))