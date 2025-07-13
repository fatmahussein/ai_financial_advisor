require "pgvector"
ActiveRecord::Type.register(:vector, Pgvector::Vector)