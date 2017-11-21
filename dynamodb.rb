require 'faker'
require 'aws-sdk'

class DynanoDB

  def dynanoDB_client_connection
    Aws::DynamoDB::Client.new(
      region: region,
      credentials: Aws::Credentials.new(access_key_id, secret_key_id),
    )
  end

  def create_table
    attribute_defs = [
      {attribute_name: 'title', attribute_type: 'S'},
      {attribute_name: 'description', attribute_type: 'S'}
    ]

    key_schema = [
      {attribute_name: 'title', key_type: 'HASH'},
    ]

    index_schema = [
      {attribute_name: 'description', key_type: 'RANGE'}
    ]

    global_indexes = [{
                        index_name: 'TitleDesc',
                        key_schema: index_schema,
                        projection: {projection_type: 'ALL'},
                        provisioned_throughput: {read_capacity_units: 5, write_capacity_units: 10}
                      }]

    request = {
      attribute_definitions: attribute_defs,
      key_schema: key_schema,
      global_secondary_indexes: global_indexes,
      table_name: 'Products_Table',
      provisioned_throughput: {read_capacity_units: 5, write_capacity_units: 10}
    }
    dynanoDB_client_connection.create_table(request)
  end

  def put_item

    dynamoDB = Aws::DynamoDB::Resource.new(region: region)
    table = dynamoDB.table('Products_Table')

    table.put_item({
                     item:
                       {
                         "ID" => rand(123456...345678),
                         "Title" => Faker::Name.name,
                         "Description" => Faker::Name.name
                       }})

  end


  def access_key_id
    ENV['AWS_ACCESS_KEY_ID']
  end

  def secret_key_id
    ENV['AWS_SECRET_ACCESS_KEY']
  end

  def region
    ENV['AWS_REGION']
  end
end

dynamodb_client = DynanoDB.new

count = 10

until count <= 0
  dynamodb_client.put_item
  count -= 1
end
