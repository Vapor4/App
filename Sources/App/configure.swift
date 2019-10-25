import Fluent
import FluentPostgresDriver
import Vapor

/// Called before your application initializes.
func configure(_ s: inout Services) {
    /// Register providers first
    s.provider(FluentProvider())

    /// Register routes
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }

    /// Register middleware
    s.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()
        
        // Serves files from `Public/` directory
        /// middlewares.use(FileMiddleware.self)
        
        // Catches errors and converts to HTTP response
        try middlewares.use(c.make(ErrorMiddleware.self))
        
        return middlewares
    }

    s.register(Database.self) { c in
        return try c.make(Databases.self).database(.psql)!
    }

    s.extend(Databases.self) { dbs, c in
        try dbs.postgres(config: c.make())
    }

    s.register(PostgresConfiguration.self) { c in
        return .init(hostname: "vapor", username: "vapor", password: "vapor")
    }

    s.register(Migrations.self) { c in
        var migrations = Migrations()
        migrations.add(CreateTodo(), to: .psql)
        return migrations
    }
}
