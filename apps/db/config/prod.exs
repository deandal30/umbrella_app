use Mix.Config

config :db, Innerpeace.Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "${DB_USER}",
  password: "${DB_PASSWORD}",
  database: "${DB_NAME}",
  hostname: "${DB_HOST}",
  pool_size: "${DB_POOL}"

# Set to AWS
config :db, arc_storage: :s3
config :arc,
  storage: Arc.Storage.S3,
  bucket: "${S3_BUCKET}",
  asset_host: "${S3_HOST}"

config :ex_aws,
  access_key_id: "${ACCESS_KEY}",
  secret_access_key: "${ACCESS_SECRET}",
  region: "ap-southeast-1",
  s3: [
    scheme: "https://",
    host: "s3.ap-southeast-1.amazonaws.com",
    region: "ap-southeast-1"
  ]

config :db, Innerpeace.Db.Hydra,
  private_link: "${HYDRA_PRIVATE}",
  public_link: "${HYDRA_PUBLIC}"

# K8 Configs
# config :db, Innerpeace.Db.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: "${DB_USER}",
#   password: "${DB_PASSWORD}",
#   database: "${DB_NAME}",
#   hostname: "${DB_HOST}",
#   pool_size: 10

# config :db, arc_storage: :s3

# config :arc,
#   storage: Arc.Storage.S3,
#   bucket: "innerpeace-payorlink-staging",
#   asset_host: "https://s3-ap-southeast-1.amazonaws.com/innerpeace-payorlink-staging"

# config :ex_aws,
#   access_key_id: "AKIAIUTN55IQTZC7DL6A",
#   secret_access_key: "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",
#   region: "ap-southeast-1"

# elixir-pdf-generator config
# config :pdf_generator,
#     command_prefix: "/usr/bin/xvfb-run"
