<?php

declare(strict_types=1);

namespace App\Core;

use PDO;
use PDOException;

class DB
{
    private static ?PDO $instance = null;

    public static function connection(): PDO
    {
        if (self::$instance === null) {
            $host   = $_ENV['DB_HOST']     ?? 'localhost';
            $dbname = $_ENV['DB_NAME']     ?? 'exp_log';
            $user   = $_ENV['DB_USER']     ?? 'postgres';
            $pass   = $_ENV['DB_PASS']     ?? '';
            $port   = $_ENV['DB_PORT']     ?? '5432';

            try {
                self::$instance = new PDO(
                    "pgsql:host={$host};port={$port};dbname={$dbname}",
                    $user,
                    $pass,
                    [
                        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::ATTR_EMULATE_PREPARES   => false,
                    ]
                );
                // Set PostgreSQL session timezone (Africa/Lusaka = UTC+2)
                $timezone = $_ENV['APP_TIMEZONE'] ?? 'Africa/Lusaka';
                self::$instance->exec("SET timezone = '{$timezone}'");
            } catch (PDOException $e) {
                error_log('DB connection failed: ' . $e->getMessage());
                http_response_code(503);
                exit('Service temporarily unavailable.');
            }
        }

        return self::$instance;
    }

    public static function query(string $sql, array $params = []): \PDOStatement
    {
        $stmt = self::connection()->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }

    public static function first(string $sql, array $params = []): array|false
    {
        return self::query($sql, $params)->fetch();
    }

    public static function all(string $sql, array $params = []): array
    {
        return self::query($sql, $params)->fetchAll();
    }

    public static function insert(string $sql, array $params = []): string
    {
        self::query($sql, $params);
        return self::connection()->lastInsertId();
    }

    public static function pdo(): PDO
    {
        return self::connection();
    }
}
