<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ChatController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
	Route::get('/chats', [ChatController::class, 'index']);
	Route::post('/chats', [ChatController::class, 'store']);
	Route::get('/chats/{chat}/messages', [ChatController::class, 'listMessages']);
	Route::post('/chats/{chat}/messages', [ChatController::class, 'addMessage']);
});

