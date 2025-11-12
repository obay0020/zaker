<?php

namespace App\Http\Controllers;

use App\Models\Chat;
use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ChatController extends Controller
{

	 // create chat with title from text
	public function store(Request $request)
{
    $validated = $request->validate([
        'text' => 'required|string|max:1000',
    ]);

    $title = Str::words($validated['text'], 5);

    $chat = Chat::create([
        'title' => $title,
    ]);

    return response()->json([
        'message' => 'Chat created',
        'chat' => [
            'id' => $chat->id,
            'title' => $chat->title,
            'date' => $chat->created_at?->toISOString(),
        ],
    ], 201);
}

///////////////////////////////////////////////////////////////////////////////////////////////
	
// get all chats order by created_at
	public function index(Request $request)
	{
		$chats = Chat::orderByDesc('created_at')->get(['id', 'title', 'created_at'])
			->map(function ($chat) {
				return [
					'id' => $chat->id,
					'title' => $chat->title,
					'date' => $chat->created_at?->toISOString(),
				];
			});

		return response()->json([
			'data' => $chats,
		]);
	}

///////////////////////////////////////////////////////////////////////////////////////////////

// get all messages of a chat order by created_at
	public function listMessages(Chat $chat)
	{
		$messages = $chat->messages()
		    ->orderBy('created_at')
			->get(['id', 'role', 'content', 'image_path', 'created_at'])
			->map(function ($message) {
				return [
					'id' => $message->id,
					'role' => $message->role,
					'content' => $message->content,
					'image_url' => $message->image_path ? Storage::url($message->image_path) : null,
					'date' => $message->created_at?->toISOString(),
				];
			});

		return response()->json([
			'chat' => [
				'id' => $chat->id,
				'title' => $chat->title,
			],
			'data' => $messages,
		]);
	}


///////////////////////////////////////////////////////////////////////////////////////////////

// add message to chat
	public function addMessage(Request $request, Chat $chat)
	{
		$validated = $request->validate([
			'role' => ['required', 'string', 'in:user,assistant,system'],
			'content' => ['sometimes', 'string'],
			'image' => ['sometimes'], 
			'image.base64' => ['sometimes', 'string'], 
			'image.filename' => ['sometimes', 'string', 'max:255'],
			'image' => ['sometimes'], 
			'title' => ['sometimes', 'string', 'max:255'],
		]);

		if (!$request->hasFile('image') && !isset($validated['image']['base64']) && !isset($validated['content'])) {
			return response()->json([
				'message' => 'Either content or image is required.',
			], 422);
		}

		$imagePath = null;
		if ($request->hasFile('image')) {
			$imagePath = $request->file('image')->store('messages', 'public');
		} elseif (isset($validated['image']['base64'])) {
			$base64 = $validated['image']['base64'];
			$decoded = null;
			$extension = 'png';

			if (str_starts_with($base64, 'data:') && str_contains($base64, ';base64,')) {
				[$meta, $data] = explode(';base64,', $base64, 2);
				$decoded = base64_decode($data, true);
				// Try to parse mime from meta: data:image/png
				if (preg_match('#^data:([\w\-\/\+\.]+)$#', $meta, $m)) {
					$mime = $m[1];
					$extension = match ($mime) {
						'image/jpeg', 'image/jpg' => 'jpg',
						'image/png' => 'png',
						'image/gif' => 'gif',
						'image/webp' => 'webp',
						default => 'png',
					};
				}
			} else {
				$decoded = base64_decode($base64, true);
			}

			if ($decoded === false || $decoded === null) {
				return response()->json([
					'message' => 'Invalid image base64 data.',
				], 422);
			}

			$filename = ($validated['image']['filename'] ?? (string) Str::uuid()).'.'.$extension;
			$path = 'messages/'.$filename;
			Storage::disk('public')->put($path, $decoded);
			$imagePath = $path;
		}

		$message = $chat->messages()->create([
			'role' => $validated['role'],
			'content' => $validated['content'] ?? '',
			'image_path' => $imagePath,
		]);

		// If this is the first message and the chat has no title yet, set it
		if (empty($chat->title)) {
			$chat->title = isset($validated['title']) && $validated['title'] !== ''
				? $validated['title']
				: Str::limit($validated['content'] ?? ($imagePath ? 'Image message' : ''), 80, '...');
			$chat->save();
		}

		return response()->json([
			'message' => 'Message added',
			'data' => [
				'id' => $message->id,
				'role' => $message->role,
				'content' => $message->content,
				'image_url' => $message->image_path ? Storage::url($message->image_path) : null,
				'date' => $message->created_at?->toISOString(),
			],
		], 201);
	}
}


