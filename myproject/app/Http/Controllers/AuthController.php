<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
	public function register(Request $request)
	{
		$validated = $request->validate([
			'name' => ['required', 'string', 'max:255'],
			'email' => ['required', 'email', 'max:255', 'unique:users,email'],
			'password' => ['required', 'string', 'min:8'],
		]);

		$user = User::create([
			'name' => $validated['name'],
			'email' => $validated['email'],
			'password' => Hash::make($validated['password']),
		]);

		return response()->json([
			'message' => 'Registration successful',
			'user' => [
				'id' => $user->id,
				'name' => $user->name,
				'email' => $user->email,
			],
		], 201);
	}

	public function login(Request $request)
	{
		$validated = $request->validate([
			'email' => ['required', 'email'],
			'password' => ['required', 'string'],
		]);

		$user = User::where('email', $validated['email'])->first();

		if (!$user || !Hash::check($validated['password'], $user->password)) {
			throw ValidationException::withMessages([
				'email' => ['The provided credentials are incorrect.'],
			]);
		}

		$token = $user->createToken('auth-token')->plainTextToken;

		return response()->json([
			'message' => 'Login successful',
			'user' => [
				'id' => $user->id,
				'name' => $user->name,
				'email' => $user->email,
			],
			'token' => $token,
		]);
	}
}


